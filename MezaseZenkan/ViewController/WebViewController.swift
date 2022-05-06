//
//  WebViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/06.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
