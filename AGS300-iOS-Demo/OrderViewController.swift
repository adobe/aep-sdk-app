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
        
        let url:String = "https://vadymus.github.io/ateng/at-order-confirmation/index.html?a=1&b=2"
        let testWithoutUrlAppend = false
        if testWithoutUrlAppend == true{
            
            let request = NSMutableURLRequest(url: URL(string: url)!)
            
            // Custom extension to sync Adobe Ids
            self.webView.syncAdobeIdentifiersBeforeWebViewLoad(webview: self.webView)
            
            self.webView.load(request as URLRequest)
        }else{
            
            let startTime1 = CFAbsoluteTimeGetCurrent()
            ACPIdentity.append (to:URL(string: url), withCallback: {(appendedURL) in
                print("appendedURL \(String(describing: appendedURL))")
                // load the url with ECID
                DispatchQueue.main.async {
                    let request = NSMutableURLRequest(url: appendedURL!)
                    let timeElapsed1 = CFAbsoluteTimeGetCurrent() - startTime1
                    print("Time elapsed for Identity:append (1 method): \(timeElapsed1) s.")
                    
                    // Custom extension to sync Adobe Ids
                    //self.webView.syncAdobeIdentifiersBeforeWebViewLoad(webview: self.webView)
                    
                    self.webView.load(request as URLRequest)
                }
            });
        }
        
        // similar example:
        let startTime2 = CFAbsoluteTimeGetCurrent()
        ACPIdentity.getUrlVariables {(urlVariables) in
            let urlStringWithVisitorData : String = "http://myUrl.com?" + urlVariables!
            let urlWithVisitorData : NSURL = NSURL(string: urlStringWithVisitorData)!
            print("urlWithVisitorData \(String(describing: urlWithVisitorData))")
            let timeElapsed2 = CFAbsoluteTimeGetCurrent() - startTime2
            print("Time elapsed for Identity:append (2 method): \(timeElapsed2) s.")
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
        let js1 = "const getCookieValue = (name) => (document.cookie.match('(^|;)\\s*' + name + '\\s*=\\s*([^;]+)')?.pop() || '');setTimeout(function(){ document.querySelector('#full_name_id').value=getCookieValue('s_ecid');},2000);/*setTimeout(function(){ document.querySelector('#street1_id').value=getCookieValue('mbox'); },3000);*/"
        
        let js2 = "if(document.querySelector('body > nav')){document.querySelector('body > nav').style.display='none'};"
        let js = "\(js1)\(js2)"
        self.webView.evaluateJavaScript(js) { (id, error) in
            print("didFinish navigation \(String(describing: id))")
            //print(error as Any)
        }
    }
        
}

