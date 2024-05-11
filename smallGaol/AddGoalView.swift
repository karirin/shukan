//
//  AddGoalView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/21.
//

import SwiftUI

struct AddGoalView: View {
    @ObservedObject var viewModel: GoalViewModel // ViewModelのインスタンスを追加
    @State private var title: String = ""
    @State private var totalCount: Int = 1
    @State private var rewardPointsText: Int = 1
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager()
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var buttonRect4: CGRect = .zero
    @State private var bubbleHeight4: CGFloat = 0.0
    @State private var buttonRect5: CGRect = .zero
    @State private var bubbleHeight5: CGFloat = 0.0
    @Binding var tutorialNum: Int
    @State private var isTitleValid: Bool = true
    @State private var selectedSample: String = "選択してください"
    private let habitSamples = ["サンプル入力","本を1冊読む", "ジョギングを3回する", "ジムに2回行く", "自炊を4回する"]
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                
                    Spacer()
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .foregroundColor(Color("fontGray"))
                    .padding(.leading,5)
                    Spacer()
                    Text("習慣を設定する")
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .foregroundColor(Color("fontGray"))
                    .padding(.trailing)
                    .opacity(0)
                }
                .padding(.bottom)
                VStack(alignment: .leading){
                    HStack{
                        Text(" ")
                            .frame(width:5,height: 20)
                            .background(Color("buttonColor"))
                        Text("習慣を入力")
                        Spacer()
                        Picker("サンプル", selection: $selectedSample) {
                            ForEach(habitSamples, id: \.self) { sample in
                                Text(sample).tag(sample)
                            }
                        }
                        .accentColor(Color("fontGray"))
                        .pickerStyle(MenuPickerStyle()) // プルダウンスタイル
//                            .overlay(
//                            RoundedRectangle(cornerRadius: 100)
//                                .stroke(.black.opacity(3), lineWidth: 1)
//                        )
                            .onChange(of: selectedSample) { newValue in
                            if newValue != "サンプル入力" {
                                title = newValue // 選択されたサンプルをタイトルに設定
                                if newValue == "本を1冊読む" {
                                    totalCount = 1
                                } else if newValue == "ジョギングを3回する" {
                                    totalCount = 3
                                } else if newValue == "ジムに2回行く" {
                                    totalCount = 2
                                } else if newValue == "自炊を4回する" {
                                    totalCount = 4
                                }
                            }
                        }
                    }
                    TextField("本を1冊読む", text: $title)
                        .border(Color.clear, width: 0)
                        .font(.system(size: 18))
                        .cornerRadius(8)
                        .onChange(of: title) { newValue in
                                isTitleValid = !newValue.isEmpty
                        }
                    Divider()
                    if isTitleValid {
                        Text("習慣が入力されていません")
                        .foregroundColor(.red)
                        .opacity(0)
                    } else {
                        Text("習慣が入力されていません")
                            .foregroundColor(.red)
                    }
                    HStack{
                        Text(" ")
                            .frame(width:5,height: 20)
                            .background(Color("buttonColor"))
                        Text("回数を入力")
                    }
                    .font(.system(size: 18))
                    HStack{
                        Text("回数 :")
                            .font(.system(size: 20))
                        TextField("回数", value: $totalCount, format: .number)
                            .border(Color.clear, width: 0)
                        //                .textFieldStyle(PlainTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.system(size: 25))
                            .cornerRadius(8)
                        
                        Slider(value: Binding(
                            get: {
                                // Slider用にIntからDoubleへの変換
                                Double(totalCount)
                            },
                            set: { (newValue) in
                                // Sliderからの値を受け取りIntへの変換
                                totalCount = Int(newValue)
                            }
                        ), in: 1...10, step: 1) // 範囲とステップ値は適宜設定
                        .accentColor(Color("buttonColor"))
//                        Divider()
//                            .frame(maxWidth:20)
                    }
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                })
                
            VStack(alignment:.leading){
                    HStack{
                        Text(" ")
                            .frame(width:5,height: 20)
                            .background(Color("buttonColor"))
                        Text("ご褒美ポイントを入力")
                    }
                    .font(.system(size: 18))
                    //            TextField("ご褒美ポイント", value: $rewardPointsText, format: .number)
                    ////                .textFieldStyle(RoundedBorderTextFieldStyle())
                    //                .keyboardType(.decimalPad)
                    //                .border(Color.clear, width: 0)
                    //                .font(.system(size: 30))
                    //            Divider()
                    //                .frame(maxWidth:50)
                    VStack {
                        HStack{
                            Image("ご褒美")
                                .resizable()
                                .frame(width:30,height:30)
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width:10,height:10)
                            TextField("", value: $rewardPointsText, formatter: NumberFormatter())
                                .font(.system(size: 25))
                            Slider(value: Binding(
                                get: {
                                    // Slider用にIntからDoubleへの変換
                                    Double(rewardPointsText)
                                },
                                set: { (newValue) in
                                    // Sliderからの値を受け取りIntへの変換
                                    rewardPointsText = Int(newValue)
                                }
                            ), in: 1...10, step: 1) // 範囲とステップ値は適宜設定
                            .accentColor(Color("buttonColor"))
                        }
                    }
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                })
                Button(action: {
                    let newGoal = Goal(id: UUID().uuidString, title: title, totalCount: totalCount, rewardPoints: rewardPointsText, userId: authManager.currentUserId!, completionDate: "")
                    isValidTitle(title)
//                    guard selectedSample != "選択してください" else {
//                                // ユーザーに警告する処理
//                        print("選択してください")
//                                return
//                            }
                    if isTitleValid {
                        viewModel.addGoal(newGoal) // ここでViewModelのメソッドを呼び出す
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("登録")
                        .frame(maxWidth:.infinity)
                }
                .padding()
                .background(Color("buttonColor"))
                .foregroundColor(.white)
                .cornerRadius(8)
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                })
                .padding(.top)
                .padding(.bottom)
                .shadow(radius: 1)
            }
            .padding()
            .foregroundColor(Color("fontGray"))
            .frame(width:.infinity)
            .background(Color("backgroundColor"))
            .onTapGesture { // タップジェスチャーを追加
                // キーボードを閉じる
                self.hideKeyboard()
            }
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey2.self) { positions in
                self.buttonRect2 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey3.self) { positions in
                self.buttonRect3 = positions.first ?? .zero
            }
            if tutorialNum == 4 {
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                    // スポットライトの領域をカットアウ
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .padding(-10)
                                .frame(width: buttonRect.width, height: buttonRect.height)
                                .position(x: buttonRect.midX, y: buttonRect.midY)
                                .blendMode(.destinationOut)
                        )
                        .ignoresSafeArea()
                        .compositingGroup()
                        .background(.clear)
                        .onTapGesture{
                            tutorialNum = 5 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                            }
                        }
                }
                VStack{
                    Spacer()
                        .frame(height: buttonRect.minY + bubbleHeight+230)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("目標を入力しましょう\n\n例\n目標を入力：本を３冊読む\n目標回数を入力：３")
                            .padding(5)
                            .font(.callout)
                            .padding(.all, 16.0)
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
                            .shadow(radius: 10)
//                            .padding(.trailing,120)
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                .onTapGesture{
                    tutorialNum = 5 // タップでチュートリアルを終了
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                    }
                }
                VStack{
                    HStack{
                        Button(action: {
                            tutorialNum = 0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }) {
                            HStack{
                                Text("スキップする")
                                    .font(.callout)
                                Image(systemName: "forward")
                            }
                            .padding(5)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            if tutorialNum == 5 {
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                    // スポットライトの領域をカットアウ
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .padding(-10)
                                .frame(width: buttonRect2.width, height: buttonRect2.height)
                                .position(x: buttonRect2.midX, y: buttonRect2.midY)
                                .blendMode(.destinationOut)
                        )
                        .ignoresSafeArea()
                        .compositingGroup()
                        .background(.clear)
                        .onTapGesture{
                            tutorialNum = 6 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                            }
                        }
                }
                VStack {
                    Spacer()
                        .frame(height: isSmallDevice() ? buttonRect.minY + bubbleHeight+60 : buttonRect.minY + bubbleHeight+80 )
                    VStack(alignment: .trailing, spacing: .zero) {
                        Text("ご褒美ポイントを入力しましょう。\n目標達成した時に取得できるご褒美ポイントを設定します。")
                            .padding(5)
                            .font(.callout)
                            .padding(.all, 16.0)
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
                            .shadow(radius: 10)
                            .padding(.leading,40)
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                .onTapGesture{
                    tutorialNum = 6 // タップでチュートリアルを終了
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                    }
                }
                VStack{
                    HStack{
                        Button(action: {
                            tutorialNum = 0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }) {
                            HStack{
                                Text("スキップする")
                                    .font(.callout)
                                Image(systemName: "forward")
                            }
                            .padding(5)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            if tutorialNum == 6 {
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                    // スポットライトの領域をカットアウ
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .frame(width: buttonRect3.width, height: buttonRect3.height)
                                .position(x: buttonRect3.midX, y: buttonRect3.midY)
                                .blendMode(.destinationOut)
                        )
                        .ignoresSafeArea()
                        .compositingGroup()
                        .background(.clear)
                        .onTapGesture{
                            tutorialNum = 0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }
                }
                VStack {
                    Spacer()
                        .frame(height: isSmallDevice() ? buttonRect.minY + bubbleHeight+320 : buttonRect.minY + bubbleHeight+380)
                    VStack(alignment: .trailing, spacing: .zero) {
                        Text("目標内容を設定できたら登録ボタンをクリックします。")
                            .padding(5)
                            .font(.callout)
                            .padding(.all, 16.0)
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
                            .shadow(radius: 10)
                            .padding(.leading,40)
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                .onTapGesture{
                    tutorialNum = 0 // タップでチュートリアルを終了
                    authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                    }
                }
                VStack{
                    HStack{
                        Button(action: {
                            tutorialNum = 0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }) {
                            HStack{
                                Text("スキップする")
                                    .font(.callout)
                                Image(systemName: "forward")
                            }
                            .padding(5)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear{
            authManager.fetchTutorialNum() { tutorialNum, error in
                if let error = error {
                    print("Error fetching tutorialNum: \(error.localizedDescription)")
                } else if let tutorialNum = tutorialNum {
                    print("Fetched tutorialNum: \(tutorialNum)")
                    // UIの更新など、fetched tutorialNumを使った処理
                    self.tutorialNum = tutorialNum
                }
            }
        }
    }
    
    func isValidTitle(_ title: String) -> Bool {
         let isValid = !title.isEmpty && title.count <= 30 // ここで独自のバリデーションルールを適用
         isTitleValid = isValid
         print("isValid:\(isValid)")
         return isValid
     }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct AddGoalView_Previews: PreviewProvider {
    @State static var dummyGoals = [Goal(id: "1", title: "Sample Goal", totalCount: 5, rewardPoints: 1, userId: "1", completionDate: "")]
    static var previews: some View {
//        AddGoalView(viewModel: GoalViewModel(), tutorialNum: .constant(0))
        TopView()
    }
}
