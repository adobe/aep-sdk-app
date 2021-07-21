//
//  OrderViewController.swift
//  AGS300-iOS-Demo
//
//  Created by Vadym Ustymenko on 12/3/19.
//  Copyright © 2019 VUES. All rights reserved.
//

import UIKit
import ACPCore
import ACPAnalytics
import ACPTarget
import WebKit

class OrderViewController: UIViewController, WKNavigationDelegate{

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            self.title = "Order Page"
        
            webView.navigationDelegate = self
        
            ACPIdentity.append (to:URL(string: "https://vadymus.github.io/ateng/at-order-confirmation/index.html"), withCallback: {(appendedURL) in
                print("appendedURL \(String(describing: appendedURL))")
                // load the url with ECID
                DispatchQueue.main.async {
                    let request = URLRequest(url: appendedURL!)
                    self.webView.load(request)
                }
            });
            // similar example:
            ACPIdentity.getUrlVariables {(urlVariables) in
                let urlStringWithVisitorData : String = "http://myUrl.com?" + urlVariables!
                let urlWithVisitorData : NSURL = NSURL(string: urlStringWithVisitorData)!
                print("urlWithVisitorData \(String(describing: urlWithVisitorData))")
                /*UIApplication.shared.open(urlWithVisitorData as URL,
                                          options: [:],
                                          completionHandler: {(complete) in
                                             // handle open success
                })*/
            }
                    
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Show prefetched Target content
//            applyPrefetchedTargetOffers()
            
            // Make Analytics page view call
            ACPCore.trackState("Second Page", data: ["customerId": "78346872782346578"])
    //        AdobeMCManager.makeAnalyticsCall(forKey: "SECOND_VIEW")

        }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor
           navigationAction: WKNavigationAction,
           decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {

        print("navigationAction \(String(describing: webView.url))")
        //link to intercept www.example.com

        // navigation types: linkActivated, formSubmitted,
        //                   backForward, reload, formResubmitted, other

        if navigationAction.navigationType == .linkActivated {
            if webView.url!.absoluteString == "http://www.example.com" {
                //do stuff

                //this tells the webview to cancel the request
                decisionHandler(.cancel)
                return
            }
        }

        //this tells the webview to allow the request
        decisionHandler(.allow)

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "if(document.querySelector('body > nav')){document.querySelector('body > nav').style.display='none'};"
        
        self.webView.evaluateJavaScript(js) { (id, error) in
            print("didFinish navigation \(String(describing: id))")
            //print(error as Any)
        }
    }
        
}
