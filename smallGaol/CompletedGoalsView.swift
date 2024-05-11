//
//  CompletedGoalsView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/22.
//

import SwiftUI

struct CompletedGoalsView: View {
    @ObservedObject var viewModel: GoalViewModel

    var body: some View {

            VStack{
                HStack{
                    Spacer()
//                        Text("目標一覧")
//                            .font(.system(size: 25))
                    Image("達成目標一覧")
                        .resizable()
                        .frame(width:180,height:35)
                        .padding(.bottom,3)
                    Spacer()
                }
                .padding(.top)
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                    Spacer()
                } else if viewModel.goals.filter { $0.goalFlag == 1 }.isEmpty {
                    // データが0件の場合は指定の画像を表示
                    Spacer()
                    VStack(spacing: -40) {
                        Text("達成した目標はありません")
                            .font(.system(size: 24))
                        Image("達成した目標")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                    Spacer()
                } else {
                let goals = viewModel.goals.filter { $0.goalFlag == 1 }
                let sortedGoals = goals.sorted { $0.completionDate
 < $1.completionDate
 }

                // 重複しない日付だけを抽出します。
                let uniqueDates = Array(Set(goals.map { $0.completionDate })).sorted()
                    ScrollView{
                        ForEach(uniqueDates, id: \.self) { date in
                            Section(header:
                                        HStack{
                                Image(systemName: "calendar.circle")
                                    .font(.system(size: 24))
                                Text(date).font(.system(size: 24))
                                Spacer()
                            }
                                .padding()
                            ) {
                                ForEach(Array(goals.filter { $0.completionDate == date }.enumerated()), id: \.element.id) { index, goal in
                                    VStack(alignment: .leading) {
                                        HStack{
                                            Image("トロフィー\(index % 9 + 1)")
                                                .resizable()
                                                .frame(width:30,height:40)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            Text(goal.title)
                                                .font(.system(size: fontSize(for: goal.title, isIPad: isIPad())))
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                    .padding()
                                }
                            }
                        }
                        Spacer()
            }
                }
        }
        .onAppear{
            viewModel.fetchGoals()
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .leading)
        .background(Color("backgroundColor"))
        .foregroundStyle(Color("fontGray"))
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
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}


#Preview {
    CompletedGoalsView(viewModel: GoalViewModel())
}
