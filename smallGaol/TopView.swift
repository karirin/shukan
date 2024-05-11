//
//  TopView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/23.
//

import SwiftUI

struct TopView: View {
    static let samplePaymentDates: [Date] = [Date()]
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var flag: Bool = false
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State var isAlert: Bool = false
    @ObservedObject var viewModel = GoalViewModel()
    
    var body: some View {
        ZStack{
            VStack {
                TabView {
                    HStack{
                        GoalView(viewModel: viewModel)
                        }
                        .tabItem {
                            Image(systemName: "house")
                                .padding()
                            Text("ホーム")
                                .padding()
                        }
                    ZStack {
                        RewardManagerView(viewModel: viewModel)
                    }
                    .tabItem {
                        Image(systemName: "gift")
                            .frame(width:1,height:1)
                        Text("ご褒美")
                    }
                    
                    ZStack {
                        CalendarView()
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                            .frame(width:1,height:1)
                        Text("カレンダー")
                    }
                        ContactTabView()
                            .tabItem {
                                Image(systemName: "headphones")
                                Text("問い合わせ")
                            }
                    ZStack {
                        SettingView()
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                }
            }
        }
    }
}

#Preview {
    TopView(viewModel: GoalViewModel())
}
