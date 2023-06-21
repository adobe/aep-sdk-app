//
//  SecondViewController.swift
/*
Copyright 2023 Adobe
All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in
accordance with the terms of the Adobe license agreement accompanying
it.
*/

import UIKit
import AEPCore
import AEPAnalytics
import AEPTarget

class LoginViewController: UIViewController {
    
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var trackActionButton: UIButton!
    @IBOutlet weak var useNameInput: UITextField!
    @IBOutlet weak var userPasswordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountMessage: UITextView!
    @IBOutlet weak var logoutButton: UIButton!
    
    open var viewControllerRef:ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if AEPSDKManager.userMembershipLevel == "" {
            self.title = "Login"
            toggleLoginControls(isLoggedIn: false)
        }else{
            self.title = "Account"
            toggleLoginControls(isLoggedIn: true)
        }
        
        
        
        // Apply Prefetched Target Offers
        applyTargetOffers()
        
        messageView.addBlurEffectToView()
        trackActionButton.addBlurEffect()
        logoutButton.addBlurEffect()
        accountMessage.addBlurEffectToView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTargetOffers),
                                               name: .applyTargetOffers,
                                               object: nil)
        
        // Make Analytics page view call
        MobileCore.track(state: "Second Page", data: ["customerId": "78346872782346578"])

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .applyTargetOffers, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCloseControllerButton(sender: AnyObject?){
        self.dismiss(animated: true) {
            //
        }
    }
    
    @IBAction func didTapLogin(sender:UIButton!) {
        print("Button Login")
        
        
        AEPSDKManager.setIdentifiersAfterUserAuthentication()
        
        // Prefetch content again
        AEPSDKManager.isContentPrefetched = false
        Target.clearPrefetchCache()
        AEPSDKManager.prefetchLocations()
        
        toggleLoginControls(isLoggedIn: true)
        
//        let aaData = AdobeMCManager.getAnalyticsData(forKey: "HOME", andSubKey: "analyticsActionData")
        MobileCore.track(action: "Login View Login Button Action", data: nil)
    }
    
    @IBAction func didTapLogout(sender:UIButton!) {
        print("Button Logout")
        AEPSDKManager.clearIdentifiersAfterUserLogout()
        
        // Prefetch content again
        AEPSDKManager.isContentPrefetched = false
        AEPSDKManager.prefetchLocations()
        
        toggleLoginControls(isLoggedIn: false)
        MobileCore.track(action: "Login View Logout Button Action", data: nil)
    }
    
    func toggleLoginControls(isLoggedIn:Bool){
        if isLoggedIn == false{
            useNameInput.isHidden = false
            userPasswordInput.isHidden = false
            loginButton.isHidden = false
            accountMessage.isHidden = true
            logoutButton.isHidden = true
            self.viewControllerRef?.accountLoginButton.setTitle("Login",for: .normal)
                
        }else{
            useNameInput.isHidden = true
            userPasswordInput.isHidden = true
            loginButton.isHidden = true
            accountMessage.isHidden = false
            logoutButton.isHidden = false
            self.viewControllerRef?.accountLoginButton.setTitle("Account",for: .normal)
        }
    }
}

// MARK: Target Implementation

extension LoginViewController{
    
    @objc func applyTargetOffers(){
        
        // Handle prefetched content
        if AEPSDKManager.isContentPrefetched == true {
            AEPSDKManager.getPrefetchedLocation(forKey: .HomePage, location: "sdk-demo-2") { (content) in
                print("prefetched content \(String(describing: content))")
                if let message = AEPSDKManager.getJsonValueFromTargetOffer(key: "message", response: content),
                    message.count > 0 {
                        print("prefetched message \(message)")
                        DispatchQueue.main.async {
                            self.messageView.text = message
                        }
                }
            }
        // Content unavailable - ensure notifications are listening for response from Target
        }else{
            print("no prefetched content found yet")
        }

    }
    
    
    
    
}

