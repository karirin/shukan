////
////  CalendarView.swift
////  smallGaol
////
////  Created by Apple on 2024/04/25.
////
//
import SwiftUI
import FSCalendar
import Firebase

class ClickDataManager: ObservableObject {
    @Published var clickDataList = [ClickData]()
    private var dbRef = Database.database().reference()
    var onUpdate: (() -> Void)?
    
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    func fetchClickData(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        dbRef.child("clicks").child(userId).observe(.value, with: { snapshot in
            var newDataList = [ClickData]()
            let dispatchGroup = DispatchGroup()  // 非同期処理を管理するためのグループ

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let goalId = dict["goalId"] as? String,
                   let goalTitle = dict["goalTitle"] as? String,
                   let date = dict["date"] as? String,
                   let completionDate = dict["completionDate"] as? String,
                   let count = dict["count"] as? Int {

                    var clickData = ClickData(id: childSnapshot.key, goalId: goalId, goalTitle: goalTitle, date: date, count: count, completionDate: completionDate)
                    
                    newDataList.append(clickData)
//                    dispatchGroup.enter()  // 非同期処理の開始をマーク
//                    self.isCompletionDateMatch(goalId: goalId, date: date) { isMatch in
//                        clickData.isCompleted = isMatch
//                        dispatchGroup.leave()  // 非同期処理の終了をマーク
//                    }
                }
            }

            dispatchGroup.notify(queue: .main) {  // 全ての非同期処理が完了した後の処理
                self.clickDataList = newDataList
                self.onUpdate?()
                completion()
            }
        })
    }
    
    func countForDate(_ date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let count = clickDataList.filter { $0.date == dateString }.reduce(0) { $0 + $1.count }
        return count
    }
    
//    func isCompletionDateMatch(goalId: String, date: String, completion: @escaping (Bool) -> Void) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            completion(false)
//            return
//        }
//
//        // 特定のgoalIdに対するリファレンスを使用してクエリを実行
//        dbRef.child("goals").child(userId).child(goalId).observeSingleEvent(of: .value, with: { snapshot in
//            if let value = snapshot.value as? [String: AnyObject],
//               let completionDate = value["completionDate"] as? String,
//               let goalFlag = value["goalFlag"] as? Int {
//                // completionDateが指定された日付と一致し、goalFlagが1（目標達成）であるかを確認
//                let isMatch = (completionDate == date) && (goalFlag == 1)
//                print("isMatch for goal \(goalId) on date \(date): \(isMatch)")
//                completion(isMatch)
//            } else {
//                // データが存在しないか、期待される形式でない場合
//                completion(false)
//            }
//        })
//    }
}

struct FSCalendarRepresentable: UIViewRepresentable {
    @ObservedObject var dataManager: ClickDataManager
    @Binding var selectedDate: Date?
    @State var goalsData: [String: Bool] = [:]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.locale = Locale(identifier: "ja_JP")
        // ヘッダーのスタイルを設定
        calendar.appearance.headerDateFormat = "yyyy年MM月"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16)
        calendar.headerHeight = 50
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        context.coordinator.dataManager = dataManager
        context.coordinator.onUpdate = {
            calendar.reloadData() // FSCalendarにビューの更新を促す
        }
        let coordinator = context.coordinator
        dataManager.onUpdate = {
            calendar.reloadData()
        }
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // ここで必要に応じてカレンダーを更新
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(dataManager: dataManager, onDateSelected: { date in
            self.selectedDate = date
        })
        // 初期化時に目標データの取得を行う
        coordinator.fetchCompletionDates()
        return coordinator
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var dataManager: ClickDataManager
        var onUpdate: (() -> Void)?  // ここでプロパティを追加
        var onDateSelected: ((Date) -> Void)?
        var updateGoalsData: (([String: Bool]) -> Void)?
        var goalsData: [String: Bool] = [:]

        init(dataManager: ClickDataManager, onDateSelected: @escaping (Date) -> Void) {
            self.dataManager = dataManager
            self.onDateSelected = onDateSelected
        }
        
        func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            onDateSelected?(date)
        }
        
        func fetchCompletionDates() {
           guard let userId = Auth.auth().currentUser?.uid else { return }

            Database.database().reference().child("goals").child(userId).observe(.value, with: { snapshot in
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
                    // ここで親のupdateGoalsDataを呼び出します
                    self.updateGoalsData?(newGoalsData)
                    self.goalsData = newGoalsData
                }
           })
       }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let dateString = formattedDate(date)
            // 同じ日にクリックされたユニークなgoalIdのセットを作成
            let uniqueGoalIds = Set(dataManager.clickDataList.filter { $0.date == dateString }.map { $0.goalId })
            // ユニークなgoalIdの数をイベント数として返す
            return uniqueGoalIds.count
        }

//        func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let dateString = dateFormatter.string(from: date)
//            if let clickData = dataManager.clickDataList.first(where: { $0.date == dateString }) {
//                print("clickData:\(clickData.count)")
//                return "\(clickData.count)"
//            }
//            return nil
//        }

        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 7 || weekday == 1 { // 7は土曜日、1は日曜日
                return UIColor.gray // 灰色に変更
            }
            return nil // 他の曜日はデフォルトの色を使用
        }
    }

}

struct CalendarView: View {
    @ObservedObject var dataManager = ClickDataManager()
    @ObservedObject var viewModel = GoalViewModel()
    @State private var selectedDate: Date? = nil
    @State private var isLoading: Bool = true
    
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack{
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(2)
                Spacer()
            } else {
                BannerView()
                    .frame(height: 70)
                FSCalendarRepresentable(dataManager: dataManager, selectedDate: $selectedDate)
                if let date = selectedDate {
                    let dateFormatter = DateFormatter()
                    let selectedDateString = formattedDate(date)
                HStack{
                    Image(systemName: "calendar.circle")
                    Text("\(selectedDateString)")
                    Spacer()
                }
                .padding(.leading)
                .font(.system(size: 20))
                let filteredData = dataManager.clickDataList.filter { $0.date == selectedDateString }
                if !filteredData.isEmpty {
                    ScrollView {
                        ForEach(dataManager.clickDataList.filter { $0.date == selectedDateString }) { clickData in
                            VStack {
                                if clickData.completionDate != "" {
                                    HStack{
                                        Image("達成")
                                            .resizable()
                                            .frame(width:20,height:20)
                                        Text("\(clickData.completionDate)に達成した習慣")
                                        Spacer()
                                    }
                                }
                                HStack{
                                    Text("\(clickData.goalTitle)")
                                    Spacer()
                                    Text("\(clickData.count)回")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .font(.system(size: 18))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                            .padding(.vertical,5)
                        }
                    }
                    }else{
                        VStack {
                            HStack{
                                Text("この日の進捗はありません")
                                    .font(.system(size: 20))
                                Spacer()
                            }
                            Image("カレンダー")
                                .resizable()
                                .frame(width:220,height:200)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
        .background(Color("backgroundColor"))
        .foregroundColor(Color("fontGray"))
        .frame(maxWidth: .infinity ,maxHeight:.infinity)
        .onAppear {
            dataManager.fetchClickData() {
                isLoading = false
                selectedDate = Date()
            }
            viewModel.fetchGoals()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
//        CalendarView()
        TopView()
    }
}



