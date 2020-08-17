//
//  DocumentViewController.swift
//  Wikit
//
//  Created by Matthew Kennard on 10/08/2020.
//  Copyright © 2020 Apps On The Move Limited. All rights reserved.
//

import UIKit
import WebKit
import DataURI

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    var webView: WKWebView!
    
    var document: UIDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let conf = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: conf)
        view.addSubview(webView)
    
        webView.configuration.userContentController.addUserScript(disableZoomScript())
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissDocumentViewController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTiddler))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { [weak self] (success) in
            if success, let document = self?.document as? Document {
                if let data = document.html, let url = document.presentedItemURL?.deletingLastPathComponent() {
                    self?.webView.load(data, mimeType: "text/html", characterEncodingName: "utf8", baseURL: url)
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    @IBAction func createNewTiddler() {
        let script = """
$tw.wiki.addTiddler(new $tw.Tiddler({title: $tw.wiki.generateNewTitle('New Tiddler')}, {created: new Date(), modified: new Date(), tags: []}))
"""
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    private func disableZoomScript() -> WKUserScript {
        let source: String = """
var meta = document.createElement('meta');
meta.name = 'viewport';
meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';
var head = document.getElementsByTagName('head')[0];
head.appendChild(meta);
"""
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}

extension DocumentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == "data" {
            DispatchQueue.global().async { [weak self] in
                if let uri = navigationAction.request.url?.absoluteString, let (data, _) = try? uri.dataURIDecoded() {
                    (self?.document as? Document)?.html = Data(data)
                    self?.document?.updateChangeCount(.done)
                }
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Make TiddlyWiki create a data URI rather than using a blob to save
        webView.evaluateJavaScript("Blob = undefined", completionHandler: nil)
    }
}

extension DocumentViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
}
