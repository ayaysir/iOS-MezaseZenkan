//
//  WebViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/06.
//

import UIKit
import WebKit
import MessageUI

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TrackingTransparencyPermissionRequest()
        
        loadHelpPage()
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
