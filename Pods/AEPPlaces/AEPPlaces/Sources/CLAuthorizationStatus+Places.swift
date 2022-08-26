/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import CoreLocation
import Foundation

/// Allows conversion of `CLAuthorizationStatus` to and from `String`
/// String values are used in EventData for Places Events and Shared State
extension CLAuthorizationStatus {
    /// Creates a `CLAuthorizationStatus` variable from the provided `String` representation
    /// If the parameter is not a recognized value, this initializer will return `.notDetermined`.
    /// - Parameter fromString: the `String` value representing a `CLAuthorizationStatus` value
    init(fromString: String) {
        switch fromString {
        case "always":
            self = .authorizedAlways
        case "wheninuse":
            self = .authorizedWhenInUse
        case "denied":
            self = .denied
        case "restricted":
            self = .restricted
        case "unknown":
            self = .notDetermined
        default:
            self = .notDetermined
        }
    }

    /// Get the `String` representation of a `CLAuthorizationStatus`
    /// - Returns: the `String` representation of `self`
    var stringValue: String {
        switch self {
        case .authorizedAlways:
            return "always"
        case .authorizedWhenInUse:
            return "wheninuse"
        case .denied:
            return "denied"
        case .notDetermined:
            return "unknown"
        case .restricted:
            return "restricted"
        @unknown default:
            return "unknown"
        }
    }
}
