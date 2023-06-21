//
//  AdobeMCManager.swift
/*
Copyright 2023 Adobe
All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in
accordance with the terms of the Adobe license agreement accompanying
it.
*/

import Foundation
import AEPTarget
import AEPCore
import AEPUserProfile
import AEPIdentity
import WebKit

enum PageName {
    case GlobalPage
    case HomePage
    case LoginPage
    case ProductsPage
    case OrderPage
}

extension Notification.Name {
    static let applyTargetOffers = Notification.Name("applyTargetOffers")
    //static let poiDataNoReloadUpdate = Notification.Name("poiDataNoReloadUpdate")
}

struct AEPSDKManager {
    
    static let locationsToPrefetch = [
        ["location": "sdk-demo-1", "params": PageName.GlobalPage ],// XT activity "Mobile AEP SDK - Prefetch POC - 1": delivers JSON offer with an image, targets AAM audience or falls back to All Visitors
        ["location": "sdk-demo-2", "params": PageName.GlobalPage ]// XT activity "Mobile AEP SDK - Prefetch POC - 2": delivers JSON offer with a message, targets AAM audience or falls back to All Visitors
        //,["location": "sdk-demo-3", "params": PageName.GlobalPage ]
        // temporarily test 3 A4T with prefetched JSON offers (named "Mobile AEP SDK - Pref A4T A/B POC - Part 1/2/3")
        ,["location": "pref-a4t-location-1", "params": PageName.GlobalPage] // activity ID 454665
                                                                            // "tnta": "454665:1:0|0,454665:1:0|2,454665:1:0|1"
        ,["location": "pref-a4t-location-2", "params": PageName.GlobalPage] // activity ID 454666
                                                                            // "tnta": "454666:2:0|0,454666:2:0|2,454666:2:0|1"
        ,["location": "pref-a4t-location-3", "params": PageName.GlobalPage] // activity ID 454667
                                                                            // "tnta": "454667:1:0|0,454667:1:0|2,454667:1:0|1"
        // 453086:0:0|0,453086:0:0|2,453086:0:0|1
        // 454665:1:0|0,454665:1:0|2,454665:1:0|1
        // 454666:2:0|0,454666:2:0|2,454666:2:0|1
        // 454667:1:0|0,454667:1:0|2,454667:1:0|1
        
        // end test
    ]
    static var isContentPrefetched = false
    static var userMembershipLevel = "" // <empty>, gold, or platinum
    static var appEntryUrlParameters = [String:String]()
    
    static func prefetchLocations () {
        print("in prefetchLocations")
        
        /* //Simulate Prefetch call failure
        AEPSDKManager.isContentPrefetched = true//DELETE//
        NotificationCenter.default.post(name: .applyTargetOffers, object: nil)//DELETE//
        */
        
        if(AEPSDKManager.isContentPrefetched == false){
            print("prefetching...")

            let locationParameters:[String:String] = AEPSDKManager.getLocationParameters(forKey: PageName.GlobalPage)
            let targetParameters = TargetParameters(parameters: locationParameters,
                                                profileParameters: nil,
                                                    order: nil, product: nil)
            var prefetchArray: [TargetPrefetch] = []
            // Build a list of defined Locations
            for (locationsData) in locationsToPrefetch {
                let location = locationsData["location"] as! String
                let prefetch = TargetPrefetch(name: location,
                                              targetParameters: targetParameters)
                prefetchArray.append(prefetch)
            }
            
            getPrefetchLocationsFromLaunchRule { newLocations in
                for location in newLocations  {
                    let prefetch = TargetPrefetch(name: location,
                                                  targetParameters: targetParameters)
                    prefetchArray.append(prefetch)
                }
                
                Target.prefetchContent(prefetchArray, with: targetParameters) { (error) in
                    if error == nil {
                        AEPSDKManager.isContentPrefetched = true
                        print("content prefetched. notifying all subscribers")
                        // Notify all listeners when content arrives
                        NotificationCenter.default.post(name: .applyTargetOffers, object: nil)
                    }else{
                        print("Target error \(String(describing: error?.localizedDescription))")
                    }
                }
            }
            
        }else{
            print("already prefetched")
        }
        
    }
    
    /**
     * Attempt to retrieve Target Locations defined in a Launch Rule
     * This feature loading Locations from Launch helps to eliminate a new version upgrade when Locations must be added/removed
     */
    static func getPrefetchLocationsFromLaunchRule (completion: @escaping ([String]) -> Void){
        var result = [String]()
        // Attempt to retrieve Locations defined in Launch rule set as Profile attrubite
        // It is a workaround for now to use Profile attributes as a storage. Ideally, we have a new feature for this
        UserProfile.getUserAttributes(attributeNames: ["TargetLocations"]) { attributes, error in
           
            
            if false, let _error = error as AEPError? {
                print("getPrefetchLocationsFromLaunchRule error \(String(describing: _error.localizedDescription))")
                completion(result)
            }else{
                print("getPrefetchLocationsFromLaunchRule attributes: \(String(describing: attributes))")
                if let rawLocations = attributes?["TargetLocations"] as? String {
                    if rawLocations.count > 0 {
                        let newLocations = rawLocations.components(separatedBy: "|")
                        if newLocations.count > 0 {
                            result.append(contentsOf: newLocations)
                        }
                    }
                }
                completion(result)
            }
        }
    }
    
    // TEST
    static func logTargetLocationDetails (withData contextData:[String:Any]? = nil, action:String, locationName:String) {
        Identity.getExperienceCloudId { (ecid, error) in
            var resultToLog = [String:Any]()
            resultToLog["timestamp"] = Int64(Date().timeIntervalSince1970 * 1000)
            resultToLog["ecid"] = ecid
            if let sessionId = UserDefaults.standard.string(forKey: "Adobe.com.adobe.module.target.session.id") {
                resultToLog["sessionId"] = sessionId
            }
            if let analyticsPayload = contextData?["analytics.payload"] {
                resultToLog["a4t"] = analyticsPayload
            }
            // TODO: send results to RUM logging tool here and optionally remove the below line
            print("\(action)|ts:\(String(describing: resultToLog["timestamp"] ?? ""))|ecid:\(resultToLog["ecid"] ?? "")|sessionId:\(resultToLog["sessionId"] ?? "")|mbox:\(resultToLog["locationName"] ?? "")|a4t:\(resultToLog["a4t"] ?? "")")
        }
    }
    
    static func getPrefetchedLocation(forKey key:PageName, location: String, completion: @escaping (String?) -> Void) {
        //print("in prefetched content location fn")
        if(AEPSDKManager.isContentPrefetched == true){
            let locationParameters:[String:String] = AEPSDKManager.getLocationParameters(forKey: key)
            let targetParameters = TargetParameters(parameters: locationParameters,
                                                            profileParameters: nil,
                                                    order: nil, product: nil)
            
            let request = TargetRequest(mboxName: location, defaultContent: "", targetParameters: targetParameters) { response, contextData in
                print("getPrefetchedLocation: Notification for \(location) \(String(describing: contextData))")
                logTargetLocationDetails(withData: contextData, action: "1", locationName: location)
                Target.displayedLocations([location], targetParameters: targetParameters)
                //contextData["analytics.payload"]
//                if let analyticsPayload = contextData?["analytics.payload"] {
//                    print("contextData[analytics.payload]: \(String(describing: analyticsPayload)) for location \(location)")
//                }
                completion(response)
                // check if App Dynamics can log Notification and A4T calls
                //logTargetLocationDetails(withData: contextData, action: "2", locationName: location)
            }
            let requests = [request]
            Target.retrieveLocationContent(requests, with: targetParameters)
            
        }else{
            //TODO: test!
            print("getPrefetchedLocation: nothing was prefetched for this location")
            completion("")
        }
        
    }

    /**
     * Loads Target content dynamically. Example: 
     * AEPSDKManager.getLocation(forKey: .GlobalPage, location: "sdk-demo-4") { (content) in
     *     print("getTargetOffers content \(String(describing: content))")
     * }
     */
    static func getLocation(forKey key:PageName, location: String, completion: @escaping (String?) -> Void){

        let locationParameters:[String:String] = AEPSDKManager.getLocationParameters(forKey: key)
        let targetParameters = TargetParameters(parameters: locationParameters,
                                                        profileParameters: nil,
                                                order: nil, product: nil)
        
        let request = TargetRequest(mboxName: location, defaultContent: "", targetParameters: targetParameters) { response in
            //print("target response: \(String(describing: response))")
            completion(response)
        }
        let requests = [request]
        Target.retrieveLocationContent(requests, with: targetParameters)
        
    }

    static func getLocationParameters(forKey key:PageName) -> [String:String]{
        var params = [
            "type":"demo"
            //,"at_property": "4b962579-c709-d8e0-2752-c2ef3c9ed3ea"
        ]
        if userMembershipLevel != ""{
            params["type"] = "gold"
        }
        switch key {
            case PageName.GlobalPage:
                params["page"] = "GlobalPage"
            case PageName.HomePage:
                params["page"] = "HomePage"
            case PageName.LoginPage:
                params["page"] = "LoginPage"
            case PageName.ProductsPage:
                params["page"] = "ProductsPage"
            case PageName.OrderPage:
                params["page"] = "OrderPage"
        }
        return params
    }
    
    static func getJsonValueFromTargetOffer(key:String, response:String?) -> String?{
        
        var result:String?
        result = nil
        
        // Process Target response
        print("Target Response \(String(describing: response))")
        let data = response?.data(using: .utf8)!
        if data != nil{
            do {
                if let contentAsJson = try JSONSerialization.jsonObject(with: data!, options : []) as? [String:Any]
                {
                    print("Target Valid JSON \(String(describing: contentAsJson))")
                    if let jsonValue:String = contentAsJson[ key ] as? String{
                        print("Target JSON Value: \(String(describing: jsonValue))")
                        result = jsonValue
                    }
                    
                } else {
                    print("Target Bad JSON")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return result
        
    }
    
    static func setIdentifiersAfterUserAuthentication(){
        
        let _ : [String: String] = ["customerID":"781456718571634714756",
                                              "anotherID":"907862348792346"];
        
        // One way to add Customer IDs
        //let identifiers : [String: String] = ["guid":"12345","hhid":"67890","secretid":"1234567890"];
        //ACPIdentity.syncIdentifiers(identifiers, authentication: .authenticated)
        
        // Fix order by setting to empty
        /*ACPIdentity.syncIdentifier("guid", identifier: "", authentication: .authenticated)
        ACPIdentity.syncIdentifier("hhid", identifier: "", authentication: .authenticated)
        ACPIdentity.syncIdentifier("secretid", identifier: "", authentication: .authenticated)*/
        
        // Set IDs - this is a better way to add multiple IDs one by one because the order persists, which is important for Target (Target uses the first ID on a list as identifier)
        Identity.syncIdentifier(identifierType: "guid", identifier: "12345", authenticationState: .authenticated)
        Identity.syncIdentifier(identifierType: "hhid", identifier: "67890", authenticationState: .authenticated)
        Identity.syncIdentifier(identifierType: "secretid", identifier: "1234567890", authenticationState: .authenticated)
        
        // Check Customer IDs
        Identity.getIdentifiers { retrievedVisitorIds, error in
            for visitorId in retrievedVisitorIds ?? [] {
//                print("visitorId type \(String(describing: visitorId.idType))")
                print("TODO: visitorId type \(String(describing: visitorId))")
            }
        }
        
        userMembershipLevel = "gold"
    }
    
    static func clearIdentifiersAfterUserLogout(){
        
        Identity.syncIdentifier(identifierType: "guid", identifier: "12345", authenticationState: .loggedOut)
        Identity.syncIdentifier(identifierType: "hhid", identifier: "67890", authenticationState: .loggedOut)
        Identity.syncIdentifier(identifierType: "secretid", identifier: "1234567890", authenticationState: .loggedOut)
        
        userMembershipLevel = ""
    }
    
}

// MARK:  Getting Target Identifiers

extension AEPSDKManager {

    /// Start collecting Customer ID (GUID), ECID, tntId, sessionId in the same order or read them from cache
    static func collectTargetIdentifiers (){
        
        //ACPTarget.resetExperience()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        print("AT-ID-EXT: from NSHomeDirectory() \(NSHomeDirectory())")
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("AT-ID-EXT Key \(key): \(value) \n")
        }
        
        // Step 0: make sure identifiers (your Customer ID, GUID) are synced before running the below
        //AEPSDKManager.setIdentifiersAfterUserAuthentication()
        
        // Step 1: get any synced identifiers first since it is a primary Target ID when visitor is authenticated
        Identity.getIdentifiers { retrievedVisitorIds, error in
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            
            // Attempt to read ECID, tntId, sessionId from cache
            var availableIdentifiers = tryReadingIdentifersFromCache()
            
            if let error = error {
                print("AT-ID-EXT: ACPCore.getIdentifiers callback error in \(timeElapsed) s.: \(error)")
            } else {
                if let visitorIds = retrievedVisitorIds{
                    
                    for visitorId/*:MobileVisitorId*/ in visitorIds {
                        print("FIXME: ")
//                        if visitorId.idType == "guid" {
//                            print("AT-ID-EXT: ACPCore.getIdentifiers callback in \(timeElapsed) s.: \(String(describing: visitorId.idType))  \(String(describing: visitorId.identifier) )")
//                            availableIdentifiers["thirdPartyId"] = visitorId.identifier
//                        }
                    }
                }else{
                    print("AT-ID-EXT: No identifiers synced")
                }
            }
            // Next step is to collect ECID
            collectExpereinceCloudId(identifiers: availableIdentifiers, startTime: startTime)
        }

    }
    
    /// Attempts to read ECID, tntId and sessionId from cache. This method is not recommended unless guided by Adobe Consultants
    static func tryReadingIdentifersFromCache () -> [String:String] {
        var result = [String:String]()
        if let sessionId = UserDefaults.standard.string(forKey: "Adobe.ADOBEMOBILE_TARGET.SESSION_ID") {
            result["sessionId"] = sessionId
        }
        if let tntId = UserDefaults.standard.string(forKey: "Adobe.ADOBEMOBILE_TARGET.TNT_ID") {
            result["tntId"] = tntId
        }
        if let ecid = UserDefaults.standard.string(forKey: "Adobe.visitorIDServiceDataStore.ADOBEMOBILE_PERSISTED_MID") {
            result["marketingCloudVisitorId"] = ecid
        }
        print("AT-ID-EXT: tryReadingIdentifersFromCache: \(result)")
        return result
    }
    
    /// Collects ECID (Marketing Cloud ID or Visitor ID) if needed, then moves on to collect tntId
    static func collectExpereinceCloudId (identifiers:[String:String], startTime:CFAbsoluteTime) {
        // Step 2: get ECID
        var result = identifiers
        if identifiers["marketingCloudVisitorId"] == nil {
            Identity.getExperienceCloudId { (ecid, error) in
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                if let error = error {
                    print("AT-ID-EXT: ACPCore.getExperienceCloudId callback in \(timeElapsed) s.; error: \(error)")
                } else {
                    print("AT-ID-EXT: ACPCore.getExperienceCloudId callback in \(timeElapsed) s.: \(String(describing: ecid))")
                    result["marketingCloudVisitorId"] = ecid
                }
                collectTntId(identifiers: result, startTime: startTime)
            }
        }else{
            collectTntId(identifiers: result, startTime: startTime)
        }
    }
    
    /// Collects tntId if needed, then moves on to post identifiers
    static func collectTntId (identifiers:[String:String], startTime:CFAbsoluteTime){
        // Step 3: get tntId
        var result = identifiers
        if identifiers["tntId"] == nil {
            // Get TNT ID with
            Target.getTntId({ tntId, error in
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("AT-ID-EXT: ACPTarget.getTntId callback in \(timeElapsed) s.: \(String(describing: tntId))")
                result["tntId"] = tntId
                postTargetIdentifiers(identifiers: result, startTime: startTime)
            })
        }else{
            postTargetIdentifiers(identifiers: result, startTime: startTime)
        }
    }
    
    /// Posts all collected Target identifiers to the subscribers
    static func postTargetIdentifiers(identifiers:[String:String], startTime:CFAbsoluteTime){
        // Step 4: get session ID if still missing
        var result = identifiers
        if identifiers["sessionId"] == nil, let sessionId = UserDefaults.standard.string(forKey: "Adobe.ADOBEMOBILE_TARGET.SESSION_ID") {
            result["sessionId"] = sessionId
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("AT-ID-EXT: postTargetIdentifiers [\(timeElapsed) seconds]: \(result)")
        
        // Step 5: post all identifiers
        NotificationCenter.default.post(name: Notification.Name("postTargetIdentifiers"), object: result)
    }
    
    /// Gets well formatted Adobe URL parameters required for seamless web view integration with native code
    static func getUrlVariablesForWebview(completion: @escaping (String?) -> Void){

        // one option is to use Identity.appendTo method
        /*Identity.appendTo(url: URL(string: url), completion: {appendedURL, error in
            print("appendedURL \(String(describing: appendedURL))")
        }*/
        
        let previewParamKeys = ["at_preview_listed_activities_only", //ex: "true"
                             "at_preview_token", //ex: "mhFIzJSF7JWb-RsnakpBqlvOU5dAZxljCIJxLpNdtiw"
                             "at_preview_index"] // ex: "7356277"
        var previewParams = ""
        previewParamKeys.forEach { paramKey in
            if let val = AEPSDKManager.appEntryUrlParameters[paramKey]{
                previewParams += "&paramKey="+val
            }
        }
        
        // but we will use similar method Identity.getUrlVariables
        Identity.getUrlVariables { (urlVariables, error) in
            if error == nil {
                Target.getSessionId { (sessionId, sessionIdErr) in
                    completion(
                        (urlVariables ?? "") +
                        previewParams +
                        ((sessionId != nil) ? "&mboxSession=" + (sessionId ?? ""): "")
                    )
                }
            }else{
                completion(previewParams)
            }
        }
    }
    
}

/**
 WKWebView extension extends Adobe Identifiers syncing between native and web views
 Author: Adobe Consulting, ustymenk@adobe.com
 */
extension WKWebView {
    /**
     Passes ECID (marketingCloudId), tntId and sessionId
     from the Native app into the Web View in order to sync visitors in the hybrid app
     Requirements: must be executed before webView.load method in order to execute Adobe related JavaScript for cookie saving
     Example:
        self.webView.syncAdobeIdentifiersBeforeWebViewLoad(webview: self.webView)
        self.webView.load(request as URLRequest)
     */
    func syncAdobeIdentifiersBeforeWebViewLoad (webview: WKWebView) {
        /// JavaScript that defined functions for cookie saving and expiration
        var jsCode = "function setAdobeCookie(cname,cvalue,exdays){const d=new Date();d.setTime(d.getTime()+(exdays*24*60*60*1000));let expires='expires='+ d.toUTCString();document.cookie=cname+'='+cvalue+';'/* +expires+';path=/'; */ };function getAdobeExpiry(addSec){return parseInt((new Date().getTime()/1000).toFixed(0))+addSec};"
        /// Try reading ECID from app's cache and wrap around JS code to save to "s_ecid" cookies
        if let ecid = UserDefaults.standard.string(forKey: "Adobe.visitorIDServiceDataStore.ADOBEMOBILE_PERSISTED_MID") {
            let ecidCookie = "setAdobeCookie('s_ecid','MCMID|\(ecid)',(365*2));"
            jsCode = jsCode + ecidCookie
        }
        /// Try reading sessionId and tntId from app's cache and wrap around JS code to save to "mbox" cookies
        if let sessionId = UserDefaults.standard.string(forKey: "Adobe.ADOBEMOBILE_TARGET.SESSION_ID"),
           let tntId = UserDefaults.standard.string(forKey: "Adobe.ADOBEMOBILE_TARGET.TNT_ID"),
           sessionId.count > 0, tntId.count > 0{
            let mboxCookie = "setAdobeCookie('mbox','session#\(sessionId)#'+getAdobeExpiry(60*30)+'|PC#\(tntId)#'+getAdobeExpiry(60*60*24*365),(365*2));"
            jsCode = jsCode + mboxCookie
        }
        print("JS code to be executed in the web view: \(jsCode)")
        /// Inject code before Document start to save all cookies into the web view
        let cookieScript = WKUserScript(source: jsCode,
                                            injectionTime: .atDocumentStart,
                                            forMainFrameOnly: false)
        /// Execute script within configuration
        webview.configuration.userContentController.addUserScript(cookieScript)
    }
}
