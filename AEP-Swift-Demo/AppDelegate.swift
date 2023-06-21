//
//  AppDelegate.swift
/*
Copyright 2023 Adobe
All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in
accordance with the terms of the Adobe license agreement accompanying
it.
*/

import UIKit

// AEP SDK imports:
import AEPCore
import AEPPlaces
import AEPMobileServices
import AEPAudience
import AEPAnalytics
import AEPTarget
import AEPIdentity
import AEPLifecycle
import AEPSignal
import AEPServices
import AEPUserProfile
import AEPAssurance

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AppTrackingService.shared.startTracking()
        
        let launchIds = [
            "launch-EN8ed0d2fc361c483f8705bb4d0d612a39-development"
        ]
        
        // AEP SDK config:
        MobileCore.setLogLevel(.debug)
        let appState = application.applicationState
        let extensions = [
            Assurance.self,
            Places.self,
            AEPMobileServices.self,
            Audience.self,
            Analytics.self,
            Target.self,
            Identity.self,
            Lifecycle.self,
            Signal.self,
            UserProfile.self
        ]
        // AEP SDK extension registration:
        MobileCore.registerExtensions(extensions, {
            MobileCore.configureWith(appId: launchIds[0])
            //Indicates how long, in seconds, Places membership information for the device will remain valid. Default value of 3600 (seconds in an hour).
            MobileCore.updateConfigurationWith(configDict: ["places.membershipttl" : 1800])
            MobileCore.updateConfigurationWith(configDict: ["target.timeout": 5]) //cause a timeout
            MobileCore.updateConfigurationWith(configDict: ["target.previewEnabled": true]) //preview for target
            //AEPCore.updateConfiguration(["target.environmentId":5062])// Prod
            if appState != .background {
                MobileCore.lifecycleStart(additionalContextData: ["contextDataKey": "contextDataVal"])
                // for demo purposes, print Traget identifiers
                AEPSDKManager.collectTargetIdentifiers()
                
                // Prefetch Target Locations on Initial App Entry
                // Note: we will also prefetch on app re-entry, see applicationWillEnterForeground
                AEPSDKManager.prefetchLocations()
            }
        })
        // see Docs https://aep-sdks.gitbook.io/docs/getting-started/get-the-sdk
        
        //AEPCore.collectLaunchInfo(launchOptions ?? [:])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        AEPSDKManager.isContentPrefetched = false //make sure we prefetch content again
        AEPSDKManager.appEntryUrlParameters = [:] //clear possible values
        AppTrackingService.shared.stopTracking()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        AppTrackingService.shared.startTracking()
        
        // Prefetch Target Locations on App Re-Entry
        AEPSDKManager.isContentPrefetched = false //clear old load
        AEPSDKManager.prefetchLocations()
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url= \(String(describing: url.absoluteString))")
        //ex: url= com.adobe.targetmobile://?at_preview_token=mhFIzJSF7JWb-RsnakpBqlvOU5dAZxljCIJxLpNdtiw&at_preview_index=1_1&at_preview_listed_activities_only=true&at_preview_evaluate_as_true_audience_ids=7356277
        
        AEPSDKManager.appEntryUrlParameters = [:]
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let queryItems = components.queryItems {
            for item in queryItems {
                AEPSDKManager.appEntryUrlParameters[item.name] = item.value!
            }
        }
        print("URL is parsed: \(AEPSDKManager.appEntryUrlParameters)")
        
        //Assurance.startSession(url: url) // start Assurance (ex Griffon) session and go to https://experience.adobe.com/#/@ags300/griffon
        
        // AEP SDK deep linking/preview
        if url.scheme == "com.adobe.targetmobile"{
            
            //AEPTarget.setPreviewRestartDeeplink(url) // preview selections
            MobileCore.collectLaunchInfo(["adb_deeplink":url.absoluteString]) // preview mode
            print("in application:app:url:options \(url)")
            return true
        }
        return false
    }
    


}

