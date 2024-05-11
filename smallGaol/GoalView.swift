//
//  GoalView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/20.
//

import SwiftUI
import Firebase

enum ActiveAlert {
    case deleteConfirmation, achievement, contact, none
}

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey2: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey3: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey4: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey5: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

//struct ClickData {
//    var goalId: String
//    var date: String
//    var count: Int
//
//    func toDictionary() -> [String: Any] {
//        return [
//            "goalId": goalId,
//            "date": date,
//            "count": count
//        ]
//    }
//}

struct GoalView: View {
    @State private var showingAddGoalView = false
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var authManager = AuthManager()
//    @StateObject var authManager = AuthManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var goalTitle = ""
    @State private var goalRewardPoint: Int = 0
    @State private var userRewardPoint: Int = 0
    @State private var alertDeleteMessage = ""
    @State private var showingDeleteAlert = false
    @State private var showingModalReward = false
    @State private var showingModalGetReward = false
    @State private var showReset = false
    @State private var goalToDeleteId: String? = nil
    @State private var goalToDeleteTitle: String? = nil
    @State private var activeAlert: ActiveAlert = .none
    @State private var showReward = false
    @State private var userFlag: Int = 0
    @State private var csFlag: Bool = false
    @State private var showAlert: Bool = false
    @State private var tutorialFlag: Bool = false
    @State private var adFlag: Bool = false
    @State private var tutorialNum: Int = 0
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
    @State var dateRangeText: String = ""
    @ObservedObject var interstitial = Interstitial()
    private let adViewControllerRepresentable = AdViewControllerRepresentable()

    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    BannerView()
                        .frame(height: 70)
//                        .padding(.top,isSmallDevice() ? -20 : -10)
                    HStack{
//                        Image("シュウカン")
//                            .resizable()
//                            .frame(width:150,height:35)
//                            .padding(.bottom,3)
//                            .padding(.leading,15)
                        ZStack{
                            Image("ご褒美ポイント")
                                .resizable()
                                .frame(width:100,height:35)
                            Text("\(userRewardPoint)")
                                .font(.system(size: 25))
                                .padding(.leading)
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                        })
                        .padding(.leading)
                        Spacer()
                        Button(action: {
                            tutorialNum =  1 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                            }
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width:35,height:35)
                                .foregroundColor(Color("fontGray"))
                        }
                        .padding(.trailing)
//                        .padding(.leading,65)
                    }
//                    .padding(.top)
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                    Spacer()
                } else if viewModel.goals.isEmpty {
                    // データが0件の場合は指定の画像を表示
                    HStack{
                        Text(" ")
                            .frame(width:10,height: 30)
                            .background(Color("buttonColor"))
                            .padding(.leading)
                        Text("\(dateRangeText)の習慣内容")
                            .font(.system(size: 30))
                        Spacer()
                    }
                    Spacer()
                        .frame(height: isSmallDevice() ? 60 : 80)
                    VStack(spacing: -40) {
                        Text("習慣がありません\n右下のプラスボタンから習慣を設定しよう")
                            .font(.system(size: 18))
                        Image("目標が無い")
                            .resizable()
                            .scaledToFit()
                            .padding(40)
                    }
                    Spacer()
                } else {
                    HStack{
                        Text(" ")
                            .frame(width:10,height: 30)
                            .background(Color("buttonColor"))
                            .padding(.leading)
                        Text("\(dateRangeText)の習慣内容")
                            .font(.system(size: 30))
                        Spacer()
                    }
                        ScrollView {
                            ForEach(viewModel.goals.sorted { $0.goalFlag < $1.goalFlag }) { goal in
                                ZStack{
                                    VStack(alignment: .leading,spacing: 8) {
                                        Text(goal.title)
                                            .font(.system(size:isSmallDevice() ? fontSizeSE(for: goal.title, isIPad: isIPad()) : fontSize(for: goal.title, isIPad: isIPad())))
//                                            .font(.system(size: fontSize(for: goalTitle, isIPad: isIPad())))
                                        HStack{
                                            Button(action: {
                                                goalToDeleteId = goal.id
                                                alertDeleteMessage = "習慣「\(goal.title)」を削除しますか？"
                                                self.activeAlert = .deleteConfirmation
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
                                            ProgressBar(value: Double(goal.currentCount), maxValue: Double(goal.totalCount), color: Color("buttonColor"))
                                                .frame(height: 30)
                                            Button(action: {
                                                viewModel.updateGoalCount(id: goal.id, increment: false) { message in
                                                }
                                                executeProcessEveryThreeTimes()
                                            }) {
                                                Image(systemName: "minus.circle")
                                            }
                                            .foregroundColor(Color("buttonColor"))
                                            .font(.system(size: 30))
                                            .disabled((goal.goalFlag != 0))
                                            Text("\(goal.currentCount) / \(goal.totalCount)")
                                                .font(.system(size: 30))
                                            // プラスボタン
                                            Button(action: {
                                                viewModel.updateGoalCount(id: goal.id, increment: true) { message in
                                                    goalTitle = goal.title
                                                    goalRewardPoint = goal.rewardPoints
                                                    activeAlert = .achievement
                                                    self.showingModalReward = true
                                                }
                                                viewModel.recordClick(goalId: goal.id, goalTitle: goal.title)
                                                executeProcessEveryThreeTimes()
                                            }) {
                                                Image(systemName: "plus.circle")
                                            }
                                            .foregroundColor(Color("buttonColor"))
                                            .padding(.trailing)
                                            .font(.system(size: 30))
                                            .disabled((goal.goalFlag != 0))
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .background((goal.goalFlag != 0) ? Color("lightGray") : .white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                    .background(GeometryReader { geometry in
                                        Color.clear.preference(key: ViewPositionKey4.self, value: [geometry.frame(in: .global)])
                                    })
                                    .padding()
                                    if goal.goalFlag == 1 {
                                        VStack{
                                            HStack{
                                                Image("達成済み")
                                                    .resizable()
                                                    .frame(width:110,height:25)
                                                Spacer()
                                            }
                                            .padding(.leading)
                                            Spacer()
                                        }
                                    }
                                }
                                .onTapGesture{
                                    showingModalGetReward = true
                                    goalRewardPoint = goal.rewardPoints
                                    goalTitle = goal.title
                                }
                            }
                            .padding(.bottom,80)
                        }
                        Spacer()
                    }
                }
                VStack {
                    Spacer() // VStackの下部にButtonを押し下げる
                    HStack {
                        Spacer() // HStackの左側にButtonを押し出す
                        Button(action: {
                            // ボタンが押された時のアクション
                            showingAddGoalView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .padding(20)
                                .background(Color("buttonColor"))
                                .foregroundColor(Color.white)
                                .clipShape(Circle())
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                        })
                        .shadow(radius: 3)
                        .padding()
                    }
                }
                .sheet(isPresented: $showingAddGoalView) {
                    AddGoalView(viewModel: viewModel, tutorialNum: $tutorialNum)
                        .presentationDetents([.large,
//                                              .height(400),
                                              // 画面に対する割合
                            .fraction(isSmallDevice() ? 0.65 : 0.55)
                        ])
                }
                if csFlag == true {
                    HelpModalView(isPresented: $csFlag, showAlert: $showAlert)
                }
                if showingModalReward {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    ModalRewardView(isPresented: $showingModalReward, goalTitle: goalTitle, goalRewardPoint: goalRewardPoint, showReward: $showReward)
                }
                if showingModalGetReward {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    ModalGetRewardView(isPresented: $showingModalGetReward, goalRewardPoint: goalRewardPoint,showReward: $showReward, goalTitle: goalTitle)
                }
                if showReward {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    ModalRewardPointView(isPresented: $showReward, goalRewardPoint: goalRewardPoint)
                }
                if showReset {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    ModalResetView(isPresented: $showReset, dateRangeText: $dateRangeText,viewModel: viewModel)
                }
                if tutorialFlag == true {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialFlag = false
                                tutorialNum = 2 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("ダウンロードありがとうございます！\n\nこのアプリは1週間の習慣をサポートするアプリです。\n最初に簡単な操作説明をします。")
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
                            tutorialFlag = false
                            tutorialNum =  2 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack{
                        HStack{
                            Button(action: {
                                tutorialFlag = false
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
                if tutorialNum == 1 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 2 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("ダウンロードありがとうございます！\n\nこのアプリは1週間の習慣をサポートするアプリです。\n最初に簡単な操作説明をします。")
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
                        Spacer()
                    }
                    .ignoresSafeArea()
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
                if tutorialNum == 2 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                Circle()
                                    .frame(width: buttonRect.width, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: buttonRect.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 3 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect.minY + bubbleHeight-100)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("右下のプラスボタンをクリックすると\n習慣を計画することができます。")
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
                                .padding(.leading,isSmallDevice() ? 10 : 40)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 3 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
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
                if tutorialNum == 3 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .frame(width: buttonRect4.width, height: buttonRect4.height)
                                    .position(x: buttonRect4.midX, y: buttonRect4.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 4 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect4.minY + bubbleHeight4 + 130)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("設定した習慣が一覧で表示されます。\n習慣の内容と習慣達成に必要な回数を確認することができます。\n進捗を記録したい場合は、プラスボタンをクリックして回数を追加してください。\n\nまた、クリックすることで、習慣達成時に取得できるご褒美ポイントの詳細を確認することができます。")
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
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 4 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
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
                if tutorialNum == 4 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .frame(width: buttonRect2.width, height: buttonRect2.height)
                                    .position(x: buttonRect2.midX, y: buttonRect2.midY)
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
                    VStack {
                        Spacer()
                            .frame(height: buttonRect2.minY + bubbleHeight2 + 60)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("こちらはユーザーが所持しているご褒美ポイントになります。\n習慣を達成すると自分が設定したご褒美ポイントが加算されます。")
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
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 5 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                        }
                    }
                    VStack{
                        Spacer()
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
                    }
                    .padding(.bottom,20)
                }
                if tutorialNum == 5 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
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
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("獲得したご褒美ポイントはご褒美一覧画面で使用することができます。\nこのアプリを使って1週間の習慣を計画して充実した毎日を過ごせるようにしましょう。")
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
                            tutorialNum =  0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
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
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey2.self) { positions in
                self.buttonRect2 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey3.self) { positions in
                self.buttonRect3 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey4.self) { positions in
                self.buttonRect4 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey5.self) { positions in
                self.buttonRect5 = positions.first ?? .zero
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .leading)
            .background(Color("backgroundColor"))
            .foregroundStyle(Color("fontGray"))
            .alert(isPresented: $showingAlert) {
                switch activeAlert {
                case .deleteConfirmation:
                    return Alert(
                        title: Text("習慣の削除"),
                        message: Text(alertDeleteMessage),
                        primaryButton: .destructive(Text("削除")) {
                            viewModel.removeGoal(id: goalToDeleteId!)
                        },
                        secondaryButton: .cancel(Text("閉じる"))
                    )
                case .achievement:
                    return Alert(
                        title: Text("習慣達成"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                case .contact:
                    return Alert(
                        title: Text("送信されました"),
                        message: Text("お問い合わせありがとうございました。"),
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
            .onAppear{
                let userDefaults = UserDefaults.standard
                if !userDefaults.bool(forKey: "hasLaunchedBeforeOnappear") {
                    // 初回起動時の処理
                    print("hasLaunchedBeforeOnappear")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        viewModel.isLoading = false
                        tutorialFlag = true
                        viewModel.fetchGoals()
                        authManager.fetchUserTimeAndCalculateRange { isSuccess in
                            if isSuccess {
                                dateRangeText = authManager.dateRangeText
                                print("dateRangeTextに値がセットされました。")
                            } else {
                                print("dateRangeTextに値のセットに失敗しました。")
                            }
                        }
                    }
                    userDefaults.set(true, forKey: "hasLaunchedBeforeOnappear")
                    userDefaults.synchronize()
                }
                authManager.updateUserDataIfNeeded { isUpdated in
                    if isUpdated {
                        print("更新が必要で、成功しました。")
                        showReset = true
                    } else {
                        print("更新は必要ありませんでした、または失敗しました。")
                    }
                }
                authManager.fetchUserFlag { userFlag, error in
                    if let error = error {
                        // エラー処理
                        print(error.localizedDescription)
                    } else if let userFlag = userFlag {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            print("executeProcessEveryFifthTimes onappear")
                            if userFlag == 0 {
                                executeProcessEveryFifthTimes()
                            }
                        }
                    }
                }
                viewModel.fetchGoals()
                authManager.fetchUserTimeAndCalculateRange { isSuccess in
                    if isSuccess {
                        dateRangeText = authManager.dateRangeText
                        print("dateRangeTextに値がセットされました。")
                    } else {
                        print("dateRangeTextに値のセットに失敗しました。")
                    }
                }
                authManager.fetchUserRewardPoint { isSuccess in
                    if isSuccess {
                        userRewardPoint = authManager.rewardPoint
                    } else {
                        
                    }
                }
            }
            
            .background {
                adViewControllerRepresentable
                  .frame(width: .zero, height: .zero)
              }
            .onChange(of: interstitial.interstitialAdLoaded) { isLoaded in
//                if isLoaded && !interstitial.wasAdDismissed && authManager.userPreFlag != 1 {
                    print("onChange interstitial.interstitialAdLoaded1")
                    if isLoaded && !interstitial.wasAdDismissed {
                        print("onChange interstitial.interstitialAdLoaded2")
                        interstitial.presentInterstitial()
                    }
              }
            .onChange(of: showingModalReward) { flag in
                authManager.fetchUserRewardPoint { isSuccess in
                    if isSuccess {
                        userRewardPoint = authManager.rewardPoint
                    } else {
                        
                    }
                }
            }
            .onChange(of: showReset) { flag in
                authManager.fetchUserTimeAndCalculateRange { isSuccess in
                    if isSuccess {
                        dateRangeText = authManager.dateRangeText
                        print("dateRangeTextに値がセットされました。")
                    } else {
                        print("dateRangeTextに値のセットに失敗しました。")
                    }
                }
            }
            .onChange(of: showAlert) { flag in
                csFlag = false
                self.activeAlert = .contact
                self.showingAlert = true
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func executeProcessEveryThreeTimes() {
        // UserDefaultsからカウンターを取得
        let count = UserDefaults.standard.integer(forKey: "AdlaunchCount") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(count, forKey: "AdlaunchCount")
        
        // 10回に1回の割合で処理を実行
        if count % 3 == 0 {
            print("executeProcessEveryThreeTimes")
            interstitial.loadInterstitial()
            interstitial.wasAdDismissed = false
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func executeProcessEveryFifthTimes() {
        // UserDefaultsからカウンターを取得
        let countForTenTimes = UserDefaults.standard.integer(forKey: "launchCountForThreeTimes") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(countForTenTimes, forKey: "launchCountForThreeTimes")
        
        // 3回に1回の割合で処理を実行
        if countForTenTimes % 10 == 0 {
            csFlag = true
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
}


#Preview {
//    GoalView(viewModel: GoalViewModel())
    TopView()
}
