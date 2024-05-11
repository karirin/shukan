//
//  AddRewardVIew.swift
//  smallGaol
//
//  Created by Apple on 2024/03/23.
//

import SwiftUI

struct AddRewardView: View {
    @ObservedObject var viewModel: GoalViewModel // ViewModelのインスタンスを追加
    @State private var title: String = ""
    @State private var totalCount: Int = 0
    @State private var rewardPointsText: Int = 1
    @State private var getFlag: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authManager = AuthManager()
    @State private var rewardPoints: Double = 1
    @State private var isTitleValid: Bool = true
    @State private var selectedSample: String = "選択してください"
    private let habitSamples = ["サンプル入力","本を買う", "映画を見に行く", "美味しいご飯を食べる", "ゲームを買う"]
    
    var body: some View {
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
                Text("ご褒美を設定する")
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
                .padding(.trailing,5)
                .opacity(0)
            }
            .padding(.bottom)
            HStack{
                Text(" ")
                    .frame(width:5,height: 20)
                    .background(Color("buttonRewardColor"))
                Text("ご褒美を入力")
                Spacer()
                Picker("サンプル", selection: $selectedSample) {
                    ForEach(habitSamples, id: \.self) { sample in
                        Text(sample).tag(sample)
                    }
                }
                .font(.system(size: 18))
                .accentColor(Color("fontGray"))
                .pickerStyle(MenuPickerStyle()) // プルダウンスタイル
                .onChange(of: selectedSample) { newValue in
                    if newValue != "サンプル入力" {
                        title = newValue // 選択されたサンプルをタイトルに設定
                    }
                }
            }
            TextField("ご褒美", text: $title)
                .border(Color.clear, width: 0)
                .font(.system(size: 18))
                .cornerRadius(8)
                .onChange(of: title) { newValue in
                        isTitleValid = !newValue.isEmpty
                }
            Divider()
            if isTitleValid {
                Text("ご褒美が入力されていません")
                .foregroundColor(.red)
                .opacity(0)
            } else {
                Text("ご褒美が入力されていません")
                    .foregroundColor(.red)
            }
            HStack{
                Text(" ")
                    .frame(width:5,height: 20)
                    .background(Color("buttonRewardColor"))
                Text("ご褒美ポイントを入力")
            }
            .font(.system(size: 18))
            
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
                    .accentColor(Color("buttonRewardColor"))
                }
            }
            Button(action: {
                let newReward = Reward(id: UUID().uuidString, title: title,rewardPoints: rewardPointsText, getFlag: getFlag, userId: authManager.currentUserId!,getFlagUpdatedDate: "")
                
                isValidTitle(title)
                if isTitleValid {
                    viewModel.addReward(newReward) // ここでViewModelのメソッドを呼び出す
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("登録")
                    .frame(maxWidth:.infinity)
            }
            .padding()
            .background(Color("buttonRewardColor"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top)
            .padding(.bottom)
            .shadow(radius: 1)
        }
        .padding()
        .foregroundColor(Color("fontGray"))
        .frame(width:.infinity,height:.infinity)
        .background(Color("backgroundColor"))
        .onTapGesture { // タップジェスチャーを追加
                // キーボードを閉じる
                self.hideKeyboard()
            }
    }
    
    func isValidTitle(_ title: String) -> Bool {
         let isValid = !title.isEmpty && title.count <= 30 // ここで独自のバリデーションルールを適用
         isTitleValid = isValid
         print("isValid:\(isValid)")
         return isValid
     }
}

struct AddRewardView_Previews: PreviewProvider {
    @State static var dummyGoals = [Goal(id: "1", title: "Sample Goal", totalCount: 5, rewardPoints: 1, userId: "1", completionDate: "")]
    static var previews: some View {
        AddRewardView(viewModel: GoalViewModel())
    }
}
