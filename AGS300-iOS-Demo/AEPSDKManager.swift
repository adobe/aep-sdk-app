//
//  AdobeMCManager.swift
//  AGS300-iOS-Demo
//
//  Created by ustymenk on 5/29/18.
//  Copyright © 2018 VUES. All rights reserved.
//

import Foundation
import ACPTarget
import ACPCore

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
        ["location": "sdk-demo-1", "params": PageName.GlobalPage ],
        ["location": "sdk-demo-2", "params": PageName.GlobalPage ],
        ["location": "sdk-demo-3", "params": PageName.GlobalPage ]
    ]
    static var isContentPrefetched = false
    static var userMembershipLevel = "" // <empty>, gold, or platinum
    
    static func prefetchLocations () {
        print("in prefetchLocations")
        
        
        if(AEPSDKManager.isContentPrefetched == false){
            print("prefetching...")

            let locationParameters:[String:String] = AEPSDKManager.getLocationParameters(forKey: PageName.GlobalPage)
            let targetParameters = ACPTargetParameters(parameters: locationParameters,
                                                           profileParameters: nil,
                                                           product: nil,
                                                           order: nil)
            var prefetchArray: [ACPTargetPrefetchObject] = []
            for (locationsData) in locationsToPrefetch {
                let location = locationsData["location"] as! String
                let prefetch = ACPTargetPrefetchObject(name: location,
                                                       targetParameters: targetParameters)
                prefetchArray.append(prefetch)
            }
            ACPTarget.prefetchContent(prefetchArray, with: targetParameters) { (error) in
                if error == nil {
                    AEPSDKManager.isContentPrefetched = true
                    print("content prefetched. notifying all subscribers")
                    // Notify all listeners when content arrives
                    NotificationCenter.default.post(name: .applyTargetOffers, object: nil)
                }else{
                    print("Target error \(String(describing: error?.localizedDescription))")
                }
            }
        }else{
            print("already prefetched")
        }
        
    }
    
    static func getPrefetchedLocation(forKey key:PageName, location: String, completion: @escaping (String?) -> Void) {
     //print("in prefetched content location fn")
        if(AEPSDKManager.isContentPrefetched == true){
            let locationParameters:[String:String] = AEPSDKManager.getLocationParameters(forKey: key)
            let targetParameters = ACPTargetParameters(parameters: locationParameters,
                                                            profileParameters: nil,
                                                            product: nil,
                                                            order: nil)
            let request = ACPTargetRequestObject(name: location, targetParameters: targetParameters, defaultContent: "") { (response) in
                print("inside prefetched content request. Will send Notification")
                ACPTarget.locationsDisplayed([location], with: targetParameters)
                completion(response)
            }
            let requests = [request]
            ACPTarget.retrieveLocationContent(requests, with: targetParameters)
            
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
        let targetParameters = ACPTargetParameters(parameters: locationParameters,
                                                        profileParameters: nil,
                                                        product: nil,
                                                        order: nil)
        
        let request = ACPTargetRequestObject(name: location, targetParameters: targetParameters, defaultContent: "") { (response) in
            //ACPTarget.locationsDisplayed([location], with: targetParameters) //<==delete
            //print("target response: \(String(describing: response))")
            completion(response)
        }
        let requests = [request]
        ACPTarget.retrieveLocationContent(requests, with: targetParameters)
        
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
        
        let identifiers : [String: String] = ["H0med3p0t2":"051b13056dee1d200s",
                                              "H0med3p0t4":"HHH0660000000629759",
                                              /*"svocid":"051b13056dee1d200s",
                                              "b2b":"051b13056dee1d200s"*/];
        
        ACPIdentity.syncIdentifiers(identifiers, authentication: .authenticated)
        
        userMembershipLevel = "gold"
    }
    
    static func clearIdentifiersAfterUserLogout(){
        userMembershipLevel = ""
    }
}



