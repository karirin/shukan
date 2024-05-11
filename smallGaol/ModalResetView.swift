//
//  ModalResetView.swift
//  smallGaol
//
//  Created by Apple on 2024/04/05.
//

import SwiftUI
import Foundation

struct ModalResetView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @ObservedObject var authManager = AuthManager()
    @Binding var dateRangeText: String
    @State private var dateRangeAgoText = ""
    @State private var lastWeekGoals: [Goal] = []
    @ObservedObject var viewModel: GoalViewModel

    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    HStack{
                        Text("期間がリセットされました！")
                            .font(.system(size: 18))
                    }
                if lastWeekGoals.isEmpty {
                    Text("前の1週間で達成した習慣はありません。")
//                        .padding()
                } else {
                    Text("\(dateRangeAgoText)で達成した習慣")
                    ForEach(lastWeekGoals) { goal in
                        Text("\(goal.title)")
//                            .padding()
                    }
                }
                Text("本日から\(dateRangeText)の習慣内容になります")
                    .font(.system(size: 16))
//                .onAppear {
//                    authManager.fetchUserTimeAndCalculateRange { isSuccess in
//                        if isSuccess {
//                            dateRangeText = authManager.dateRangeText
//                            print("dateRangeTextに値がセットされました。")
//                        } else {
//                            print("dateRangeTextに値のセットに失敗しました。")
//                        }
//                    }
//
//                }
                }
                .frame(maxWidth:.infinity)
                .padding(20)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                .padding(.horizontal,20)
                
                HStack{
                    Spacer()
                    Button(action: {
                        if isButtonActive {
                            isPresented = false // 現在の画面を閉じる
                        }
                    }) {
                        HStack{
                            Text("次へ")
                            
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color("backgroundColor"))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                    .disabled(!isButtonActive)
                }
                .padding(.trailing,40)
                .cornerRadius(8)
                .shadow(radius: 10)
            }
        }
        .foregroundColor(Color("fontGray"))
        .onAppear {
            viewModel.fetchAchievedGoalsForLastWeek { achievedGoals in
                self.lastWeekGoals = achievedGoals
                print("self.lastWeekGoals:\(self.lastWeekGoals)")
            }
            let today = Date()
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日" // 日付のフォーマットを設定
            self.dateRangeText = dateFormatter.string(from: oneWeekAgo) // 計算した日付を設定
        }
    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 6
            } else if text.count >= 11 {
                return baseFontSize - 4
            } else if text.count >= 8 {
                return baseFontSize - 2
            } else {
                return baseFontSize
            }
        }
    }
}

#Preview {
    ModalResetView(isPresented: .constant(false), dateRangeText: .constant("test"), viewModel: GoalViewModel())
}
