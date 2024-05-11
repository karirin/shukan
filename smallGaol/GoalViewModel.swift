//
//  GoalViewModel.swift
//  smallGaol
//
//  Created by Apple on 2024/03/20.
//

import SwiftUI
import Firebase

struct ClickData: Identifiable, Codable {
    var id: String = UUID().uuidString
    var goalId: String
    var goalTitle: String
    var date: String
    var count: Int
    var completionDate:String

    func toDictionary() -> [String: Any] {
        return [
            "goalId": goalId,
            "goalTitle": goalTitle,
            "date": date,
            "count": count,
            "completionDate": completionDate
        ]
    }
}

struct Goal: Identifiable {
    var id: String
    var title: String
    var currentCount: Int = 0
    var totalCount: Int
    var rewardPoints: Int
    var goalFlag: Int = 0
    var userId: String
    var completionDate: String
}

extension Goal {
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userId = value["userId"] as? String,
            let title = value["title"] as? String,
            let currentCount = value["currentCount"] as? Int,
            let totalCount = value["totalCount"] as? Int,
            let rewardPoints = value["rewardPoints"] as? Int,
            let goalFlag = value["goalFlag"] as? Int,
            let completionDate = value["completionDate"] as? String
        else {
            return nil
        }
        self.id = snapshot.key
        self.userId = userId
        self.title = title
        self.currentCount = currentCount
        self.totalCount = totalCount
        self.rewardPoints = rewardPoints
        self.goalFlag = goalFlag
        self.completionDate = completionDate
    }

    func toDictionary() -> [String: Any] {
        return [
            "userId": userId, // ユーザーIDを辞書に含める
            "title": title,
            "currentCount": currentCount,
            "totalCount": totalCount,
            "rewardPoints": rewardPoints,
            "goalFlag": goalFlag, // goalFlagを辞書に含める
            
            "completionDate": completionDate
        ]
    }
}

struct Reward: Identifiable {
    var id: String
    var title: String
    var rewardPoints: Int
    var getFlag: Int
    var userId: String
    var getFlagUpdatedDate: String
}

extension Reward {
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userId = value["userId"] as? String,
            let title = value["title"] as? String,
            let getFlag = value["getFlag"] as? Int,
            let rewardPoints = value["rewardPoints"] as? Int,
            let getFlagUpdatedDate = value["getFlagUpdatedDate"] as? String
        else {
            return nil
        }
        self.id = snapshot.key
        self.userId = userId
        self.title = title
        self.getFlag = getFlag
        self.rewardPoints = rewardPoints
        self.getFlagUpdatedDate = getFlagUpdatedDate
    }

    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "title": title,
            "getFlag": getFlag,
            "rewardPoints": rewardPoints,
            "getFlagUpdatedDate": getFlagUpdatedDate
        ]
    }
}

class GoalViewModel: ObservableObject {
    @Published var goals = [Goal]()
    @Published var rewards = [Reward]()
    private var db = Database.database().reference()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @ObservedObject var authManager = AuthManager()
    @Published var isLoading = true
    @Published var clickDataList = [ClickData]()
    @Published var goalsData: [String: Bool] = [:]
    
    func fetchAchievedGoalsForLastWeek(completion: @escaping ([Goal]) -> Void) {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        fetchGoals()
        let lastWeekGoals = goals.filter { goal in
            if let completionDate = dateFormatter.date(from: goal.completionDate), goal.goalFlag == 1 {
                return completionDate >= startDate && completionDate <= endDate
            }
            return false
        }
        completion(lastWeekGoals)
    }

    func fetchGoals() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        db.child("goals").child(userId).observe(.value, with: { snapshot in
            var newGoals = [Goal]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let goal = Goal(snapshot: snapshot) {
                    newGoals.append(goal)
                }
            }
            self.goals = newGoals
//            print("self.goals:\(self.goals)")
            self.isLoading = false
        })
    }
    
    func fetchCompletionDates() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.child("goals").child(userId).observe(.value, with: { snapshot in
            var newGoalsData = [String: Bool]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: AnyObject],
                   let completionDate = value["completionDate"] as? String,
                   let goalFlag = value["goalFlag"] as? Int,
                   goalFlag == 1 { // goalFlagが1なら達成されたとみなします
                    
                    // 日付のフォーマットを確認し、それが期待するフォーマットであることを保証する
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let date = dateFormatter.date(from: completionDate) {
                        let dateString = dateFormatter.string(from: date)
                        newGoalsData[dateString] = true
                    }
                }
            }
            // 完了した日付のデータを更新
            DispatchQueue.main.async {
                self.goalsData = newGoalsData
            }
        })
    }
    
    func fetchRewards() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        db.child("rewards").child(userId).observe(.value, with: { snapshot in
            var newRewards = [Reward]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let reward = Reward(snapshot: snapshot) {
                    newRewards.append(reward)
                }
            }
            self.rewards = newRewards
            self.isLoading = false
            print("fetchRewards:\(self.isLoading)")
        })
    }
    
    func recordClick(goalId: String, goalTitle: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is unavailable.")
            return
        }

        let userClickRef = db.child("clicks").child(userId)
        userClickRef.queryOrdered(byChild: "date").queryEqual(toValue: dateString).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists(), let children = snapshot.value as? [String: Any] {
                for (key, value) in children {
                    if let existingData = value as? [String: Any], existingData["goalId"] as? String == goalId {
                        // Found existing record for the same goalId and date, increment count
                        let existingCount = (existingData["count"] as? Int ?? 0) + 1
                        userClickRef.child(key).updateChildValues(["count": existingCount])
                        print("Incremented count for existing record.")
                        return
                    }
                }
            }
            // No existing record found, create new one
            let newClickData = ClickData(goalId: goalId, goalTitle: goalTitle, date: dateString, count: 1,completionDate: "")
            userClickRef.childByAutoId().setValue(newClickData.toDictionary()) { error, _ in
                if let error = error {
                    print("Error saving click data: \(error.localizedDescription)")
                } else {
                    print("Successfully saved new click data.")
                }
            }
        }) { error in
            print("Error retrieving clicks: \(error.localizedDescription)")
        }
    }
    
    // GoalViewModelクラスのメソッドを変更
    func updateGoalCount(id: String, increment: Bool, onExceed: @escaping (String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is unavailable.")
            return
        }
        
        if let index = goals.firstIndex(where: { $0.id == id }) {
            var updatedGoal = goals[index]
            updatedGoal.currentCount += increment ? 1 : -1
            updatedGoal.currentCount = max(0, updatedGoal.currentCount)

            // 目標達成時の処理
            if updatedGoal.currentCount >= updatedGoal.totalCount && updatedGoal.goalFlag == 0 {
                updatedGoal.goalFlag = 1 // 目標達成フラグを設定
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // 日付の形式を設定
                let dateString = dateFormatter.string(from: currentDate) // 日付を文字列に変換

                onExceed("習慣「\(updatedGoal.title)」を達成しました！\nご褒美ポイント\(updatedGoal.rewardPoints)ポイント獲得！")
                authManager.updateRewardPoint(additionalPoints: updatedGoal.rewardPoints) { success, _ in
                    if success {
                        print("Reward points updated successfully.")
                    } else {
                        print("Failed to update reward points.")
                    }
                }

                guard let userId = Auth.auth().currentUser?.uid else {
                    print("ユーザーがログインしていません")
                    return
                }

                let goalRef = db.child("goals").child(userId).child(updatedGoal.id)
                goalRef.updateChildValues([
                    "currentCount": updatedGoal.currentCount,
                    "goalFlag": updatedGoal.goalFlag,
                    "completionDate": dateString
                ])

                // Clicksテーブルの該当データを更新
                let userClickRef = db.child("clicks").child(userId)
                userClickRef.queryOrdered(byChild: "goalId").queryEqual(toValue: id).observeSingleEvent(of: .value) { snapshot in
                    if let children = snapshot.children.allObjects as? [DataSnapshot] {
                        for child in children {
                            if let clickData = child.value as? [String: AnyObject], clickData["date"] as? String == dateString {
                                let clickRef = userClickRef.child(child.key)
                                clickRef.updateChildValues(["completionDate": dateString])
                                print("Updated click data for completion date.")
                                return
                            }
                        }
                    }
                }
            } else {
                // 目標未達成時の処理: 単にカウントを更新します。
                let goalRef = db.child("goals").child(userId).child(updatedGoal.id)
                goalRef.updateChildValues(["currentCount": updatedGoal.currentCount])
            }
        }
    }


    func removeGoal(id: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        db.child("goals").child(userId).child(id).removeValue { error, _ in
            if let error = error {
                // エラーハンドリング
                print("Error removing goal: \(error)")
            } else {
                print("削除成功　removeGoal")
                // Firebaseから削除に成功したらローカルの配列も更新
                DispatchQueue.main.async {
                    self.goals.removeAll { $0.id == id }
                }
            }
        }
    }
    
    func removeReward(id: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        db.child("rewards").child(userId).child(id).removeValue { error, _ in
            if let error = error {
                // エラーハンドリング
                print("Error removing goal: \(error)")
            } else {
                print("削除成功　removeGoal")
                // Firebaseから削除に成功したらローカルの配列も更新
                DispatchQueue.main.async {
                    self.rewards.removeAll { $0.id == id }
                }
            }
        }
    }
    
    
    func createSampleGoal() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません createSampleGoal")
            return
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 日付の形式を設定
        let dateString = dateFormatter.string(from: currentDate) // 日付を文字列に変換
        
        let ref = Database.database().reference() // Realtime Databaseの参照を取得
          let sampleData: [String: Any] = [
              "completionDate": dateString,
              "currentCount": 0,
              "goalFlag": 0,
              "rewardPoints": 3,
              "title": "【サンプル】ジョギングを３回する",
              "totalCount": 3,
              "userId": userId
          ]
          // "goals"ノードにサンプルデータを追加
       ref.child("goals").child(userId).childByAutoId().setValue(sampleData) { error, _ in
              if let error = error {
                  print("Error saving data: \(error.localizedDescription)")
              } else {
                  print("Successfully saved data.")
              }
          }
        self.isLoading = false
    }
    
    func createSampleReward() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません createSampleGoal")
            return
        }
        
        let ref = Database.database().reference() // Realtime Databaseの参照を取得
          let sampleData: [String: Any] = [
              "getFlagUpdatedDate": "",
              "getFlag": 0,
              "rewardPoints": 3,
              "title": "【サンプル】マッサージを受ける",
              "userId": userId
          ]
          // "goals"ノードにサンプルデータを追加
       ref.child("rewards").child(userId).childByAutoId().setValue(sampleData) { error, _ in
              if let error = error {
                  print("Error saving data: \(error.localizedDescription)")
              } else {
                  print("Successfully saved data.")
              }
          }
        self.isLoading = false
    }

    
    func addGoal(_ goal: Goal) {
        // Firebase Authenticationから現在のユーザーIDを取得
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        // 新しいGoalにユーザーIDを設定
        var newGoal = goal
        newGoal.userId = userId

        // Firebaseで新しいキーを自動生成し、その下にGoalを保存
        let newGoalRef = db.child("goals").child(userId).childByAutoId()
        newGoalRef.setValue(newGoal.toDictionary()) { error, reference in
            if let error = error {
                // エラーハンドリング
                print("Error adding goal: \(error)")
            } else {
                // 成功時にGoalのidを更新し、UI等に反映
                DispatchQueue.main.async {
                    var updatedGoal = newGoal
                    updatedGoal.id = reference.key! // 生成された一意のキーをGoalのidとして設定
                    // self.goals.append(updatedGoal) // 更新されたGoalをリストに追加等、必要に応じてUIを更新
                }
            }
        }
    }

    func updateRewardGetFlag(rewardId: String, newFlag: Int) {
        // Firebase Authenticationから現在のユーザーIDを取得
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        // DateFormatterを使用して現在の日付をYYYY-MM-DD形式に変換
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // 指定されたrewardIdの下の参照を取得
        let rewardRef = db.child("rewards").child(userId).child(rewardId)

        // getFlagとgetFlagUpdatedDateの値を更新する
        rewardRef.updateChildValues([
            "getFlag": newFlag,
            "getFlagUpdatedDate": dateString // 日付の文字列を使用
        ]) { error, _ in
            if let error = error {
                print("updateRewardGetFlag2")
                // エラーハンドリング
                print("Error updating reward getFlag: \(error)")
            } else {
                print("updateRewardGetFlag3")
                // フラグと更新日時の更新に成功したらローカルの配列も更新
                DispatchQueue.main.async {
                    if let index = self.rewards.firstIndex(where: { $0.id == rewardId }) {
                        self.rewards[index].getFlag = newFlag
                        // 更新日時のフィールドはここでローカルのモデルに追加する必要があるかもしれません
                    }
                }
                print("getFlagと更新日時が更新されました")
            }
        }
    }
    
    func addReward(_ reward: Reward) {
        // Firebase Authenticationから現在のユーザーIDを取得
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        // 新しいGoalにユーザーIDを設定
        var newReward = reward
        newReward.userId = userId

        // Firebaseで新しいキーを自動生成し、その下にGoalを保存
        let newRewardRef = db.child("rewards").child(userId).childByAutoId()
        newRewardRef.setValue(newReward.toDictionary()) { error, reference in
            if let error = error {
                // エラーハンドリング
                print("Error adding goal: \(error)")
            } else {
                // 成功時にGoalのidを更新し、UI等に反映
                DispatchQueue.main.async {
                    var updatedReward = newReward
                    updatedReward.id = reference.key!
                }
            }
        }
    }
}


#Preview {
    TopView(viewModel: GoalViewModel())
}
