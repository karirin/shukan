//
//  Interstitial.swift
//  chatAi
//
//  Created by Apple on 2024/02/26.
//

import SwiftUI
import GoogleMobileAds

class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    @Published var flag: Bool = false
    @Published var wasAdDismissed = false
    
    var interstitialAd: GADInterstitialAd?
    
    // リワード広告の読み込み
    func loadInterstitial() {
//        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { (ad, error) in // テスト
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-4898800212808837/5739399848", request: GADRequest()) { (ad, error) in
            if let _ = error {
                print("😭: 読み込みに失敗しました")
                self.interstitialAdLoaded = false
                print("self.interstitialAdLoaded = false 4")
                return
            }
            print("😍: 読み込みに成功しました")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.interstitialAdLoaded = true
                print("loadInterstitial() self.interstitialAdLoaded:\(self.interstitialAdLoaded)")
//            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
//    func presentInterstitial(from viewController: UIViewController) {
//      guard let fullScreenAd = interstitialAd else {
//        return print("Ad wasn't ready")
//      }
//
//      fullScreenAd.present(fromRootViewController: viewController)
//    }
    
    func presentInterstitial() {
        let root = UIApplication.shared.windows.first?.rootViewController
        if let ad = interstitialAd {
            ad.present(fromRootViewController: root!)
            self.interstitialAdLoaded = false
            print("self.interstitialAdLoaded = false 1")
        } else {
            print("😭: 広告の準備ができていませんでした")
            self.interstitialAdLoaded = false
            self.loadInterstitial()
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }
    
    // 失敗通知
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        print("self.interstitialAdLoaded = false 2")
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
//        self.interstitialAdLoaded = false // 広告表示時に false に設定
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false // 広告閉じた時に false に設定
        print("self.interstitialAdLoaded = false 3")
        self.wasAdDismissed = true
//        loadInterstitial()  // 新しい広告をロード
    }
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}

struct Interstitial1: View {
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
        @ObservedObject var interstitial = Interstitial()
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .background {
                        adViewControllerRepresentable
                          .frame(width: .zero, height: .zero)
                      }
        }
        .onAppear {
            interstitial.presentInterstitial()
            interstitial.loadInterstitial()
        }
    }
}

#Preview {
    Interstitial1()
}
