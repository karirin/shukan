//
//  rewardView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/23.
//

import SwiftUI

enum ActiveRewardAlert {
    case deleteConfirmation, reward, noneReward, none
}

struct TopTabView: View {
    let list: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< list.count, id: \.self) { row in
                Button(action: {
                    withAnimation {
                        selectedTab = row
                    }
                }, label: {
                    VStack(spacing: 0) {
                        HStack {
                            Text(list[row])
                                .font(Font.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("fontGray"))
                        }
                        .frame(
                            width: (UIScreen.main.bounds.width / CGFloat(list.count)),
                            height: 48 - 3
                        )
                        Rectangle()
                            .fill(selectedTab == row ? Color("buttonRewardColor") : Color.clear)
                            .frame(height: 3)
                    }
                    .fixedSize()
                })
            }
        }
//        .frame(height: 48)
        .background(Color("backgroundColor"))
        .compositingGroup()
//        .shadow(color: .primary.opacity(0.2), radius: 3, x: 4, y: 4)
    }
}

struct RewardManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var canSwipe: Bool = false
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    @ObservedObject var authManager = AuthManager()
    @State private var userRewardPoint: Int = 0
    @ObservedObject var viewModel: GoalViewModel
    @State private var showingAddRewardView = false
    @State private var tutorialStart = false
    @State private var onChangeRewardPoint = false
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State var rewardTitle = ""

    let list: [String] = ["ご褒美一覧", "ご褒美履歴"]
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    BannerView()
                        .frame(height: 70)
//                        .padding(.top,isSmallDevice() ? -20 : -10)
//                        .padding(.bottom,-10)
                    HStack{
                        if selectedTab == 0 {
                            ZStack{
                                Image("ご褒美ポイント")
                                    .resizable()
                                    .frame(width:100,height:35)
                                Text("\(userRewardPoint)")
                                    .font(.system(size: 25))
                                    .padding(.leading)
                            }
                            .padding(.leading)
                            Spacer()
//                            Image("ご褒美一覧")
//                                .resizable()
//                                .frame(width:140,height:35)
//                                .padding(.bottom,3)
//                            Spacer()
                            Button(action: {
                                tutorialNum =  7 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
                                }
                                tutorialStart = true
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .resizable()
                                    .frame(width:35,height:35)
                                    .foregroundColor(Color("fontGray"))
                            }
                            .padding(.trailing)
//                            .padding(.leading,35)
                        } else {
                            Spacer()
                            Image("ご褒美履歴")
                                .resizable()
                                .frame(width:140,height:35)
                                .padding(.bottom,10)
                            Spacer()
                        }
                    }
                    
                    TopTabView(list: list, selectedTab: $selectedTab)
                    
                    TabView(selection: $selectedTab,
                            content: {
                        RewardView(viewModel: viewModel, rewardTitle: $rewardTitle, userRewardPoint: $userRewardPoint, onChangeRewardPoint: $onChangeRewardPoint, tutorialNum: tutorialNum, tutorialStart: $tutorialStart)
                            .tag(0)
                            .padding(.bottom,isSmallDevice() ? -150 : -180)
                        GetRewardView(viewModel: viewModel)
                            .tag(1)
                            .padding(.bottom,isSmallDevice() ? -160 : -190)
                    })
                }
                VStack {
                    Spacer() // VStackの下部にButtonを押し下げる
                    HStack {
                        Spacer() // HStackの左側にButtonを押し出す
                        Button(action: {
                            // ボタンが押された時のアクション
                            showingAddRewardView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .padding(20)
                                .background(Color("buttonRewardColor"))
                                .foregroundColor(Color.white)
                                .clipShape(Circle())
                        }
                        .opacity(selectedTab == 0 ? 1 : 0)
                        
                        .shadow(radius: 3)
                        .padding() // ボタン周りに余白を追加
                    }
                }
                .sheet(isPresented: $showingAddRewardView) {
                    AddRewardView(viewModel: viewModel)
                        .presentationDetents([.large,
//                                              .height(400),
                                              // 画面に対する割合
                                              .fraction(isSmallDevice() ? 0.55 : 0.45)
                        ])
                }
                if tutorialNum == 7 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .frame(width: buttonRect.width, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: buttonRect.midY - 180)
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
                        VStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: .zero) {
                                Text("「ご褒美一覧」画面では設定した自分へのご褒美が表示されています。\nクリックするとご褒美ポイントを消費してご褒美を選べます。\n選んだご褒美は「ご褒美履歴」画面で確認することができます。")
                                    .font(.callout)
                                    .padding(5)
                                    .font(.system(size: 24.0))
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
                            .onTapGesture{
                                tutorialNum =  2 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                }
                            }
                            VStack{
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        tutorialNum = 0 // タップでチュートリアルを終了
                                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                        }
                                    }) {
                                        HStack{
                                            Text("閉じる")
                                                .font(.callout)
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
                                }
                            }
                            Spacer()
                        }
                        
                        .ignoresSafeArea()
                        .onTapGesture{
                            tutorialNum = 0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }
                    }
                }
                if onChangeRewardPoint {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    ModalGetReward(isPresented: $onChangeRewardPoint, goalTitle: rewardTitle)
                }
            }
            .onAppear{
                viewModel.fetchRewards()
                authManager.fetchUserRewardPoint { isSuccess in
                    if isSuccess {
                        userRewardPoint = authManager.rewardPoint
                    } else {
                        
                    }
                }
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
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .leading)
//            .navigationBarBackButtonHidden(true)
            .background(Color("backgroundColor"))
            .foregroundColor(Color("fontGray"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct RewardView: View {
    @State private var showingAddRewardView = false
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var authManager = AuthManager()
    @State private var showingAlert = false
    @Binding var rewardTitle: String
    @State private var alertMessage = ""
    @State private var alertDeleteMessage = ""
    @Binding var userRewardPoint: Int
    @State private var rewardPoint: Int = 0
    @State private var rewardId = ""
    @State private var showingDeleteAlert = false
    @State private var showGetReward = false
    @Binding var onChangeRewardPoint: Bool
    @State private var goalToDeleteId: String? = nil
    @State private var goalToDeleteTitle: String? = nil
    @State private var activeRewardAlert: ActiveRewardAlert = .none
    @State var tutorialNum: Int
    @Binding var tutorialStart: Bool
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    } else if viewModel.rewards.filter { $0.getFlag == 0 }.isEmpty {
                        // データが0件の場合は指定の画像を表示
                        Spacer()
                        VStack(spacing: -60) {
                            Text("ご褒美がありません\n右下のプラスボタンからご褒美を設定しよう")
                                .font(.system(size: 18))
                            Image("ご褒美が無い")
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            ForEach(viewModel.rewards.filter { $0.getFlag == 0 }) { reward in
                                VStack(alignment: .leading) {
                                    Text(reward.title)
                                        .font(.system(size:isSmallDevice() ? fontSizeSE(for: reward.title, isIPad: isIPad()) : fontSize(for: reward.title, isIPad: isIPad())))
                                    HStack{
                                        ZStack{
                                            Image("ご褒美ポイント")
                                                .resizable()
                                                .frame(width:100,height:35)
                                                .padding(.trailing)
                                            Text("\(reward.rewardPoints)")
                                                .font(.system(size: 25))
                                        }
                                        Spacer()
                                        Button(action: {
                                            rewardId = reward.id
                                            alertDeleteMessage = "ご褒美「\(reward.title)」を削除しますか？"
                                            self.activeRewardAlert = .deleteConfirmation
                                            self.showingAlert = true
                                        }) {
                                            HStack {
                                                Image(systemName: "trash")
                                            }
                                            .padding(5)
                                            .foregroundColor(.gray)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .background(userRewardPoint >= reward.rewardPoints ? Color.white : Color("lightGray"))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding()
                                .onTapGesture{
                                    showingAlert = true
                                    if userRewardPoint >= reward.rewardPoints {
                                        activeRewardAlert = .reward
                                        rewardTitle = reward.title
                                        rewardPoint = reward.rewardPoints
                                        rewardId = reward.id
                                    } else {
                                        activeRewardAlert = .noneReward
                                        rewardPoint = reward.rewardPoints - self.authManager.rewardPoint
                                    }
                                }
                            }
                            .padding(.bottom,80)
                        }
                        Spacer()
                    }
                }
                .alert(isPresented: $showingAlert) {
                    switch activeRewardAlert {
                    case .deleteConfirmation:
                        return Alert(
                            title: Text("ご褒美の削除"),
                            message: Text(alertDeleteMessage),
                            primaryButton: .destructive(Text("削除")) {
                                viewModel.removeReward(id: rewardId)
                            },
                            secondaryButton: .cancel(Text("閉じる"))
                        )
                    case .reward:
                        return Alert(
                            title: Text("ご褒美の選択"),
                            message: Text("ご褒美「\(rewardTitle)」を選択しますか？"),
                            primaryButton: .destructive(Text("選択する")) {
                                authManager.decreaseRewardPoint(decrementPoints: rewardPoint) { success,id  in
                                    print("aaaa2")
                                    if success {
                                        viewModel.updateRewardGetFlag(rewardId: rewardId,newFlag: 1)
                                        onChangeRewardPoint = true
                                        authManager.fetchUserRewardPoint { isSuccess in
                                            if isSuccess {
                                                onChangeRewardPoint = true
                                            } else {
                                                
                                            }
                                        }
                                        print("ポイントが正常に減らされました。")
                                    } else {
                                        print("ポイントの減算に失敗しました。")
                                    }
                                    print("aaaa")
                                }
                                print("aaaa1")
                            },
                            secondaryButton: .cancel(Text("閉じる"))
                        )
                    case .noneReward:
                        return Alert(
                            title: Text("ご褒美ポイント不足"),
                            message: Text("ご褒美ポイントが\(rewardPoint)ポイント不足しています"),
                            dismissButton: .default(Text("OK"))
                        )
                    case .none:
                        return Alert(
                            title: Text("エラー"),
                            message: Text("不明なアラートです"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .leading)
                .background(Color("backgroundColor"))
                .foregroundStyle(Color("fontGray"))
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
            .onAppear{
                viewModel.fetchRewards()
                authManager.fetchUserRewardPoint { isSuccess in
                    if isSuccess {
                        
                            print("authManager.rewardPoint:\(authManager.rewardPoint)")
                        userRewardPoint = authManager.rewardPoint
                    } else {
                        
                    }
                }
                
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
            .onChange(of: tutorialStart) { flag in
                print("onchange tutorialStart")
                authManager.fetchTutorialNum() { tutorialNum, error in
                    if let error = error {
                        print("Error fetching tutorialNum: \(error.localizedDescription)")
                    } else if let tutorialNum = tutorialNum {
                        print("Fetched tutorialNum: \(tutorialNum)")
                        // UIの更新など、fetched tutorialNumを使った処理
                        self.tutorialNum = tutorialNum
                        tutorialStart = false
                    }
                }
            }
            .onChange(of: onChangeRewardPoint) { flag in
                print("onChange onChangeRewardPoint")
                authManager.fetchUserRewardPoint { isSuccess in
                    if isSuccess {
                        userRewardPoint = authManager.rewardPoint
                    } else {
                        
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
                return baseFontSize - 10
            } else if text.count >= 12 {
                return baseFontSize - 6
            } else if text.count >= 10 {
                return baseFontSize - 4
            } else if text.count >= 8 {
                return baseFontSize - 2
            } else {
                return baseFontSize
            }
        }
    }
    
    func fontSizeSE(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 12
            } else if text.count >= 12 {
                return baseFontSize - 10
            } else if text.count >= 10 {
                return baseFontSize - 8
            } else if text.count >= 8 {
                return baseFontSize - 6
            } else {
                return baseFontSize
            }
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

struct GetRewardView: View {
    @State private var showingAddRewardView = false
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var authManager = AuthManager()
    @State private var showingAlert = false
    @State private var rewardTitle = ""
    @State private var alertMessage = ""
    @State private var alertDeleteMessage = ""
    @State private var rewardPoint: Int = 0
    @State private var rewardId = ""
    @State private var showingDeleteAlert = false
    @State private var goalToDeleteId: String? = nil
    @State private var goalToDeleteTitle: String? = nil
    @State private var activeRewardAlert: ActiveRewardAlert = .none
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            ZStack{
                VStack {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    } else if viewModel.rewards.filter { $0.getFlag == 1 }.isEmpty {
                        // データが0件の場合は指定の画像を表示
                        Spacer()
                        VStack(spacing: -40) {
                            Text("ご褒美履歴はありません")
                                .font(.system(size: 24))
                            Image("ご褒美履歴画像")
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            let rewardsWithIndex = viewModel.rewards.filter { $0.getFlag == 1 }
                                .enumerated()
                                .map { ($0.offset, $0.element) }
                            let rewards = viewModel.rewards.filter { $0.getFlag == 1 }
                            let sortedRewards = rewards.sorted { $0.getFlagUpdatedDate < $1.getFlagUpdatedDate }
                            
                            // 重複しない日付だけを抽出します。
                            let uniqueDates = Array(Set(rewards.map { $0.getFlagUpdatedDate })).sorted()
                            
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
                                    ForEach(rewardsWithIndex.filter { $0.1.getFlagUpdatedDate == date }, id: \.0) { index, reward in
                                        HStack{
                                            Image("ギフト\(index % 9 + 1)")
                                                .resizable()
                                                .frame(width:30,height:40)
                                                .padding(.bottom,5)
                                                .padding(.trailing,5)
                                            VStack(alignment: .leading) {
                                                Text(reward.title)
                                                    .font(.system(size: 30))
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 3)
                                        .padding(.horizontal)
                                        .padding(.bottom)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    NavigationLink("", destination: AddRewardView(viewModel:viewModel).navigationBarBackButtonHidden(true), isActive: $showingAddRewardView)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                .background(Color("backgroundColor"))
                .foregroundStyle(Color("fontGray"))
                .onAppear{
                    viewModel.fetchRewards()
                    authManager.fetchUserRewardPoint { isSuccess in
                        if isSuccess {
                        } else {
                            
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
//    GetRewardView(viewModel: GoalViewModel())
//    RewardView(viewModel: GoalViewModel(),tutorialNum: 1, tutorialStart: .constant(false))
//    RewardManagerView(viewModel: GoalViewModel())
    TopView()
}
