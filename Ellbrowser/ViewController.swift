//
//  ViewController.swift
//  Ellbrowser
//
//  Created by ThunderRa1n on 2017/03/18.
//  Copyright © 2017- ThunderRa1n. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UISearchBarDelegate {
    var webView: WKWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var urlString: String!
    private var refreshControl: UIRefreshControl!
    private var statusBarBackground: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButon: UIBarButtonItem!
    @IBOutlet weak var oneFixible: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var twoFixible: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var threeFixible: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var forFixible: UIBarButtonItem!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let minus = 88 + barHeight
        let myWidth: CGFloat = self.view.bounds.width
        let myHeight: CGFloat = self.view.bounds.height
        webView = WKWebView(frame: CGRect(x: 0, y: barHeight + 44, width: myWidth, height: myHeight - minus), configuration: webConfiguration)
        webView.uiDelegate = self
        self.webView.navigationDelegate = self
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.gray
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let myURL = URL(string: "https://www.ellpedia.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        self.view.addSubview(webView)
        webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        addRefreshControl()
        webView.allowsBackForwardNavigationGestures = true
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: myWidth, height: barHeight))
        statusBar.autoresizingMask = [.flexibleWidth]
        statusBar.backgroundColor = UIColor.darkGray
        view.addSubview(statusBar)
    }
    
    //page loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.searchBar.text = self.webView.url?.absoluteString
    }
    
    @objc func pullToRefresh() {
        self.refreshControl.endRefreshing()
        self.webView.reload()
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reload")
        refreshControl.addTarget(self, action: #selector(ViewController.pullToRefresh), for:.valueChanged)
        self.webView.scrollView.addSubview(refreshControl)
        
        self.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar.text!)
        searchBar.endEditing(true)
    }
    
    func search(_ urlString: String){
        var urlString = urlString
        if(urlString == ""){
            return;
        }
        
        var strUrl: String
        var searchWord:String = ""
        let chkURL = urlString.components(separatedBy: ".")
        if chkURL.count > 1 {
            //case URL
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            } else {
                strUrl = "http://"
                urlString = strUrl.appending(urlString)
            }
        } else {
            // case keyword
            urlString = urlString.replacingOccurrences(of: "?", with: " ")
            let words = urlString.components(separatedBy: " ")
            searchWord = words.joined(separator: "+")
            urlString = "https://www.ellpedia.com/search?q=\(searchWord)"
        }
        let encodedurlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedurlString!)
        let request = URLRequest(url: url!)
        self.webView.load(request)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "loading")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress"{
    //change progress
    self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
    }else if keyPath == "loading"{
    UIApplication.shared.isNetworkActivityIndicatorVisible = self.webView.isLoading
    if self.webView.isLoading {
    self.progressView.setProgress(0.1, animated: true)
    }else{
    //set 0 when loading is done
    self.progressView.setProgress(0.0, animated: false)
    }
    }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.webView.goBack()
    }
    
    @IBAction func forwardButton(_ sender: UIBarButtonItem) {
        self.webView.goForward()
    }
    
    
    @IBAction func homeButton(_ sender: UIBarButtonItem) {
        webView.load(URLRequest(url: URL(string: "https://www.ellpedia.com")!))
    }
    
    @IBAction func actionButton(_ sender: UIBarButtonItem) {
        let acURL = URL(string: (self.webView.url?.absoluteString)!)
        let controller = UIActivityViewController(activityItems: [acURL as Any], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
     @IBAction func historyButton(_ sender: UIBarButtonItem) {
        let title: String = self.webView.title!
        let url:URL = self.webView.url!
        let alert: UIAlertController = UIAlertController(title: "Add to Reading List?", message: "Add the current page to Reading List in Safari App", preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // when button is pushed
            (action: UIAlertAction!) -> Void in
            guard SSReadingList.supportsURL(url) else {
                return
            }
            do {
                try SSReadingList.default()?.addItem(with: url, title: title, previewText: nil)
            } catch {
                print(error)
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{
            // when button is pushed
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        // display alert dialog
        let otherAction = UIAlertAction(title: "OK", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // display confirm dialog
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView else {
            return
        }
        let statusBar = statusBarWindow.subviews[0] as UIView
        statusBar.backgroundColor = UIColor.black
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // display prompt dialog
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly:false], completionHandler: { (finished: Bool) in
                })
            }
            else {
                // deprecated on ios10
                UIApplication.shared.open((url), options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }
        else if !url.absoluteString.hasPrefix("http://")
            && !url.absoluteString.hasPrefix("https://") {
            // URL Scheme in info.plist?
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open((url), options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil
                || !navigationAction.targetFrame!.isMainFrame {
                // when push <a href="..." target="_blank">
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
        case .backForward:
            break
        case .formResubmitted:
            break
        case .formSubmitted:
            break
        case .other:
            break
        case .reload:
            break
        }
        
        decisionHandler(.allow)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

