//
//  ViewController.swift
//  AGS300-iOS-Demo
//
//  Created by ustymenk on 5/18/18.
//  Copyright © 2018 VUES. All rights reserved.
//

import UIKit

// AEP SDK imports:
import ACPAnalytics
import ACPTarget
import ACPCore

let notificationTargetUpdate = Notification.Name.init(rawValue: "notificationTargetUpdate")

class ViewController: UIViewController, NSURLConnectionDelegate {
    
    @IBOutlet weak var homeImage: UIImageView?
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var trackActionButton: UIButton!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var accountLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("in viewDidLoad")
        self.title = "Home"
        
        
        
//        ACPTarget.getTntId({ (id) in
//            print("ACPTarget.getTntId \(String(describing: id))")
//        })
        
        // Apply Prefetched Target Offers when they are ready
        prehideTestedContent(timeout: 5)
        applyTargetOffers()
        
        bannerView.addBlurEffectToView()
        trackActionButton.addBlurEffect()
        nextPageButton.addBlurEffect()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("in viewWillAppear")
        
        if AEPSDKManager.userMembershipLevel == "" {
            accountLoginButton.setTitle("Login",for: .normal)
        }else{
            accountLoginButton.setTitle("Account",for: .normal)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTargetOffers),
                                               name: .applyTargetOffers,
                                               object: nil)
        
        ACPCore.trackState("Home Page", data: ["myCustomVar": "mobile training"])
        
        // TEST for a THD banner
        self.getTargetOffers()
        
        // TEST get all IDs
        ACPCore.getSdkIdentities { (str, err) in
            if (err == nil) {
                print("\nSuccess - ACPCore.getSDKIdentities: \(String(describing: str)) \n\n")
                
                /*
                 {\n  \"users\" : [\n    {\n      \"userIDs\" : [\n        {\n          \"namespace\" : \"4\",\n          \"type\" : \"namespaceId\",\n          \"value\" : \"50036599245714044285895756617772295350\"\n        }\n      ]\n    }\n  ],\n  \"companyContexts\" : [\n    {\n      \"namespace\" : \"imsOrgID\",\n      \"value\" : \"EB9CAE8B56E003697F000101@AdobeOrg\"\n    }\n  ]\n}
                 */
                /*
                 {\n  \"users\" : [\n    {\n      \"userIDs\" : [\n        {\n          \"namespace\" : \"4\",\n          \"type\" : \"namespaceId\",\n          \"value\" : \"50036599245714044285895756617772295350\"\n        }\n      ]\n    }\n  ],\n  \"companyContexts\" : [\n    {\n      \"namespace\" : \"imsOrgID\",\n      \"value\" : \"EB9CAE8B56E003697F000101@AdobeOrg\"\n    }\n  ]\n}
                 */
                
                
            } else {
                print("Error - ACPCore.getSDKIdentities: string:\(String(describing: str)) error:\(String(describing: err))")
            }
        }

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .applyTargetOffers, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapButtonAction(sender:UIButton!) {
        print("Button Clicked")
        //let aaData = AdobeMCManager.getAnalyticsData(forKey: "HOME", andSubKey: "analyticsActionData")
        
        ACPCore.trackAction("Home Button Action", data: nil)
    }
    
    
    
    private func connection(connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        print("RESPONSE IS \(String(describing: response))")
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoginViewController"){
        
            let lvc = segue.destination as? LoginViewController
            lvc?.viewControllerRef = self
            
        }
    }
    
    
    
}

// MARK: Target Implementation

// AEP SDK Displaying Target Offers

extension ViewController{
    
    // Pre-hides personalized content
    func prehideTestedContent(timeout:Double){
        self.homeImage?.alpha = 0
        self.messageLabel?.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.homeImage?.alpha = 1
            self.messageLabel?.alpha = 1
        }
    }
    
    /**
     * Applies Target Offers that were prefetched on app entry; triggers Notifications calls for prefetched content
     * Note: if prefetched content failed to load due to offline mode, then this will trigger an Execute call
     */
    @objc func applyTargetOffers(){
        
        // You could safely check here for AEPSDKManager.isContentPrefetched == true
        // however, if Prefetch call failed - the below will trigger an Execute call instead
            
        // Change banner
        AEPSDKManager.getPrefetchedLocation(forKey: .HomePage, location: "sdk-demo-1") { (content) in
            print("prefetched content (sdk-demo-1) \(String(describing: content))")
            if let image = AEPSDKManager.getJsonValueFromTargetOffer(key: "image", response: content) {
                DispatchQueue.main.async {
                    switch image{
                        case "adobe": self.homeImage?.image = UIImage(named: "adobe")
                        case "iphone": self.homeImage?.image = UIImage(named: "iphone")
                        case "galaxy": self.homeImage?.image = UIImage(named: "galaxy")
                        default: print ("showing default image because response is: \(image)")
                    }
                    self.homeImage?.alpha = 1 // reveal pre-hidden personalized content
                }
            }else{
                DispatchQueue.main.async {
                    self.homeImage?.alpha = 1
                }
            }
        }
            
        // Change message on Home page
        AEPSDKManager.getPrefetchedLocation(forKey: .HomePage, location: "sdk-demo-2") { (content) in
            print("prefetched content (sdk-demo-2) \(String(describing: content))")
            if let message = AEPSDKManager.getJsonValueFromTargetOffer(key: "message", response: content),
                message.count > 0 {
                    print("prefetched message \(message)")
                    DispatchQueue.main.async {
                        self.messageLabel.text = message
                        self.messageLabel?.alpha = 1
                    }
            }else{
                DispatchQueue.main.async {
                    self.messageLabel?.alpha = 1 // reveal pre-hidden personalized content
                }
            }
        }

    }
    
    
    @objc func getTargetOffers(){
        print("in getTargetOffers")
        // Handle prefetched content
        AEPSDKManager.getLocation(forKey: .GlobalPage, location: "sdk-demo-5") { (content) in
            print("getTargetOffers content \(String(describing: content))")
            if let bannerValue = AEPSDKManager.getJsonValueFromTargetOffer(key: "banner", response: content),
                bannerValue.count > 0 {
                    print("Target message \(bannerValue)")
                    DispatchQueue.main.async {
                        guard let bannerUrl = bannerValue as String?, bannerUrl.count > 0 else {
                                print("Hi there)")
                                return
                        }
                        self.homeImage?.load(url: URL(string: bannerUrl)!)
                    }
            }
        }

    }

    

}

extension UIButton
{
    func addBlurEffect()
    {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.bounds
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        if let imageView = self.imageView{
            self.bringSubview(toFront: imageView)
        }
    }
}
extension UIView
{
    func addBlurEffectToView()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        //self.addSubview(blurEffectView)
        self.insertSubview(blurEffectView, at: 0)
    }
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        self?.alpha = 1
                    }
                }
            }
        }
    }
}



    
    
