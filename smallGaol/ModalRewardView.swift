//
//  ModalReturnView.swift
//  moneyQuiz
//
//  Created by hashimo ryoya on 2023/12/18.
//

import SwiftUI

struct ModalRewardView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @State var goalTitle: String
    @State var goalRewardPoint: Int
    @Binding var showReward: Bool
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    HStack{
                        Image("クラッカー1")
                            .resizable()
                            .frame(width:30,height: 30)
                            .padding(.bottom,5)
                        Text("習慣達成")
                            .font(.system(size: 30))
                            .padding(.horizontal,5)
//                            .padding(.top,5)
                        Image("クラッカー2")
                            .resizable()
                            .frame(width:30,height: 30)
                            .padding(.bottom,5)
                    }
                    Text("\(goalTitle)")
                        .font(.system(size: fontSize(for: goalTitle, isIPad: isIPad())))
                    Text("を達成しました！")
                        .font(.system(size: 20))
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
                            showReward = true // ご褒美獲得画面を表示
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
                //            .padding(10)
                .cornerRadius(8)
                .shadow(radius: 10)
                //            .padding()
            }
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

struct ModalGetRewardView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @State var goalRewardPoint: Int
    @Binding var showReward: Bool
    @State var goalTitle: String
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    Text("\(goalTitle)")
                        .font(.system(size: fontSize(for: goalTitle, isIPad: isIPad())))
                    Text("を習慣達成で取得できるご褒美ポイント")
                        .font(.system(size: 16))
                      HStack{
                         Image("ご褒美")
                             .resizable()
                             .frame(width:40,height:40)
                         Image(systemName: "plus")
                             .font(.system(size: 30))
                         Text("\(goalRewardPoint)")
                             .font(.system(size: 30))
                      }
                }
                .frame(maxWidth:.infinity)
                .padding(15)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                
                HStack{
                    Spacer()
                    Button(action: {
                       isPresented = false // 現在の画面を閉じる
                    }) {
                        HStack{
                            Text("戻る")
                            
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
                //            .padding(10)
                .cornerRadius(8)
                .shadow(radius: 10)
                //            .padding()
            }
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

struct ModalRewardPointView: View {
    @Binding var isPresented: Bool
//        @ObservedObject var authManager = AuthManager.shared
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @State var goalRewardPoint: Int
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    Text("ご褒美ポイント\(goalRewardPoint)ポイント獲得")
                        .font(.system(size: 20))
                    HStack{
                        Image("ご褒美")
                            .resizable()
                            .frame(width:50,height:50)
                        Text("+")
                            .font(.system(size: 40))
                        Text("\(goalRewardPoint)")
                            .font(.system(size: 40))
                    }
                }
                .padding(20)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.top,50)
//                .padding(.trailing)
                
                HStack{
                    Spacer()
                    Button(action: {
                        if isButtonActive {
                            isPresented = false
                        }
                    }) {
                        HStack{
                            Text("戻る")
                            
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color("backgroundColor"))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                    .disabled(!isButtonActive)
                }
                .padding(10)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                .padding(.trailing)
            }
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

struct ModalGetReward: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
//    @Binding var showReward: Bool
    @State var goalTitle: String
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    HStack{
                        Image("クラッカー1")
                            .resizable()
                            .frame(width:30,height: 30)
                            .padding(.bottom,5)
                        Text("ご褒美獲得")
                            .font(.system(size: 30))
                            .padding(.horizontal,5)
    //                            .padding(.top,5)
                        Image("クラッカー2")
                            .resizable()
                            .frame(width:30,height: 30)
                            .padding(.bottom,5)
                    }
                    Text("\(goalTitle)")
                        .font(.system(size: fontSize(for: goalTitle, isIPad: isIPad())))
                    Text("「ご褒美履歴画面」から確認できます")
                        .font(.system(size: 16))
                }
                .frame(maxWidth:.infinity)
                .padding(15)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                
                HStack{
                    Spacer()
                    Button(action: {
                       isPresented = false // 現在の画面を閉じる
                    }) {
                        HStack{
                            Text("戻る")
                            
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
                //            .padding(10)
                .cornerRadius(8)
                .shadow(radius: 10)
                //            .padding()
            }
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
//    ModalRewardView(isPresented: .constant(false), goalTitle: "本を３冊読む", goalRewardPoint: 3, showReward: .constant(false))
//    GoalView(viewModel: GoalViewModel())
//    ModalRewardPointView(isPresented: .constant(false), goalRewardPoint: 1)
//    TopView()
    ModalGetReward(isPresented: .constant(false), goalTitle: "test")
}
