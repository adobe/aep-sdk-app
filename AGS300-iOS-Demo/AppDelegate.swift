//
//  AppDelegate.swift
//  AGS300-iOS-Demo
//
//  Created by ustymenk on 5/18/18.
//  Copyright © 2018 VUES. All rights reserved.
//

import UIKit

// AEP SDK imports:
import ACPCore
import ACPGriffon
import ACPPlacesMonitor
import ACPPlaces
import ACPMobileServices
import ACPAudience
import ACPAnalytics
import ACPTarget
import ACPUserProfile

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let appState = application.applicationState;
        
        AppTrackingService.shared.startTracking()
        
        // AEP SDK config:
        ACPCore.setLogLevel(.debug)
        let launchIds = [
            "launch-EN8ed0d2fc361c483f8705bb4d0d612a39-development"
        ]
        ACPCore.configure(withAppId: launchIds[0])
                
        // AEP SDK extension registration:
        ACPGriffon.registerExtension()
        ACPPlacesMonitor.registerExtension()
        ACPPlaces.registerExtension()
        ACPMobileServices.registerExtension()
        ACPAudience.registerExtension()
        ACPAnalytics.registerExtension()
        ACPTarget.registerExtension()
        ACPIdentity.registerExtension()
        ACPLifecycle.registerExtension()
        ACPSignal.registerExtension()
        ACPUserProfile.registerExtension()
        ACPCore.start {
            
            //Indicates how long, in seconds, Places membership information for the device will remain valid. Default value of 3600 (seconds in an hour).
            ACPCore.updateConfiguration(["places.membershipttl" : 1800])
            ACPCore.updateConfiguration(["target.timeout": 5]) //cause a timeout
            //ACPCore.updateConfiguration(["target.environmentId":5062])// Prod
            
            
            if appState != .background {
                
                ACPCore.lifecycleStart(nil)
                ACPPlacesMonitor.start()
                
                // for demo purposes, print Traget identifiers
                AEPSDKManager.collectTargetIdentifiers()
                
                // Prefetch Target Locations on Initial App Entry
                // Note: we will also prefetch on app re-entry, see applicationWillEnterForeground
                AEPSDKManager.prefetchLocations()
            }
            
        }
        // see Docs https://aep-sdks.gitbook.io/docs/getting-started/get-the-sdk
        
        //ACPCore.collectLaunchInfo(launchOptions ?? [:])
        
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
        
        // AEP SDK deep linking/preview
        if url.scheme == "com.adobe.targetmobile"{
            
            //ACPTarget.setPreviewRestartDeeplink(url) // preview selections
            ACPCore.collectLaunchInfo(["adb_deeplink":url.absoluteString]) // preview mode
            print("in application:app:url:options \(url)")
            return true
        }
        return false
    }
    


}

