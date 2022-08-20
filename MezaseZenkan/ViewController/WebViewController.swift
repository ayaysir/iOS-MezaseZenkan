//
//  WebViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/06.
//

import UIKit
import WebKit
import MessageUI

protocol WebVCDelegate: AnyObject {
    func didChangedBannerRes(_ controller: WebViewController)
}

class WebViewController: UIViewController {
    
    weak var delegate: WebVCDelegate?
    let toggleHighResButtonText = [
        "レースバナーを高画質に交換",
        "レースバナーを基本画像に交換",
    ]
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var btnToggleRaceBannerRes: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToggleResButtonText()
    }
    
    private func setToggleResButtonText() {
        if UserDefaults.standard.bool(forKey: .cfgShowHighResBanner) {
            btnToggleRaceBannerRes.tintColor = nil
            btnToggleRaceBannerRes.setTitle(toggleHighResButtonText[1], for: .normal)
        } else {
            btnToggleRaceBannerRes.tintColor = .systemPink
            btnToggleRaceBannerRes.setTitle(toggleHighResButtonText[0], for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TrackingTransparencyPermissionRequest()
        
        loadHelpPage()
    }
    
    private func closeViewAndReload() {
        delegate?.didChangedBannerRes(self)
        dismiss(animated: true)
    }
    
    @IBAction func btnActChangeHighResBannerImage(_ sender: UIButton) {
        if !UserDefaults.standard.bool(forKey: .cfgShowHighResBanner) {
            simpleDestructiveYesAndNo(self, message: "レースのバナー画像を高精細画像に置き換えますか？", title: "レースのバナー画像を交換") { _ in
                UserDefaults.standard.set(true, forKey: .cfgShowHighResBanner)
                self.closeViewAndReload()
            }
        } else {
            UserDefaults.standard.set(false, forKey: .cfgShowHighResBanner)
            closeViewAndReload()
        }
        
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    
    func loadHelpPage() {
        // 웹 파일 로딩
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let pageName = "index"
        guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "MezaseZenkan Manual") else {
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    // 링크 클릭시 외부 사파리 브라우저에서 열리게 하기
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard case .linkActivated = navigationAction.navigationType,
              let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
   }
}

extension WebViewController: MFMailComposeViewControllerDelegate {
    
    @IBAction func launchEmail(sender: UIButton) {
  // 1
        guard MFMailComposeViewController.canSendMail() else {
            // 사용자의 메일 계정이 설정되어 있지 않아 메일을 보낼 수 없다는 경고 메시지 추가
            simpleAlert(self, message: "ユーザーのメールアカウントが設定されていないため、メールを送信できません。")
            return
        }
        
  // 2
        let emailTitle = "Feedback of MezaseZenkan" // 메일 제목
        let messageBody =
        """
        OS Version: \(UIDevice.current.systemVersion)
        
        
        """
        
  // 3
        let toRecipents = ["yoonbumtae@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    // 4
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
    }
    
}
