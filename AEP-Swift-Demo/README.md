#  AEP SDK Demo App

> This demo app demonstrates best practices implementation for Adobe Target with AEP SDK. 


## AEP SDK Implementation:

1. Importing and registering extensions (see `AppDelegate`)
2. Deep linking for visual preview (see `application(_:open:options:)`)


## Prefetching Target Experiences

### Where to prefetch 

Target activity experiences can be prefetched on the following major app entry points:

   - initial App load (see `AppDelegate.application(_:didFinishLaunchingWithOptions:)`)
   - App Re-entry (see `AppDelegate.applicationWillEnterForeground(_:)`)

### Pre-hiding 

Pre-hiding app content we test on app entry positively affects user experience. While Target call is in action, temporarily hiding content allows to not expose default content. Good practice includes:

  - Prehide content (see `ViewController.viewDidLoad`)
  - Make a call to Target and then apply personalized content
  - Unhide content
   
   a. Location "sdk-demo-1", activity "Mobile AEP SDK - Prefetch POC - 1" (see `ViewController.applyTargetOffers()`)
     - Delivers JSON to change Home view logo
   b. Location "sdk-demo-2", activity "Mobile AEP SDK - Prefetch POC - 2 - Membership Targeting"
     - Delivers JSON to change Home, Login views with promo message
     - Targets membership level: gold, platinum or none
   c. Location "sdk-demo-3", empty experience
     
     
## Loading Target Experiences Dynamically

Target activity to load dynamically for geo targeting

   a. Location "sdk-demo-4", activity "Mobile AEP SDK - Geo POC - POI Name" (see `ProductTableViewController`)
      - Delivers JSON offer to show promo message



## ID Synchronization for Visitor Identification

Sending one or multiple customer IDs to Adobe for identification:
`ACPIdentity.syncIdentifiers(identifiers, authentication: .authenticated)` 
    - See `LoginViewController.didTapLogin`
    - Fetch Target offers again if necessary to re-qualify to different activities after login



## Syncing Native Code with Web Views

1. Appending ECID with `ACPIdentity.append` or `ACPIdentity.getUrlVariables` (see `OrderViewController`)



## Target Order Confirmation Location

1. TODO: Sending order confirmation Location to Target


## Places Extension

- POIs entered in Places Service (https://experience.adobe.com/#/@ags300/places)
- Launch rule set (see  https://docs.adobe.com/content/help/en/places/using/use-places-with-other-solutions/places-target/places-target.html)
- Target activity created (see section "Loading Target Activities")


## In-App Messaging

- TODO Send a real time notification when someone enters a POI, "Hey..welcome to the stadium."



## Analytics Extension

- TODO
