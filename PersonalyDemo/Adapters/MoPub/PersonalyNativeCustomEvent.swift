//
//  PersonalyNativeCustomEvent.swift
//  PersonalyMoPubAdapter
//
//  Created by Mobexs on 11/14/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import Personaly
import MoPub

@objc(PersonalyNativeCustomEvent)
public class PersonalyNativeCustomEvent: MPNativeCustomEvent {

    static let kPersonalyNativeAdReviewsCountKey = "kPersonalyNativeAdReviewsCountKey"
    static let kPersonalyNativeAdAppDeveloperKey = "kPersonalyNativeAdAppDeveloperKey"
    static let kPersonalyNativeAdAppStoreIDKey = "kPersonalyNativeAdAppStoreIDKey"
    static let kPersonalyNativeAdAppStoreURLKey = "kPersonalyNativeAdAppStoreURLKey"
    static let kPersonalyNativeAdCategoriesKey = "kPersonalyNativeAdCategoriesKey"
    static let kPersonalyNativeAdPrivacyPolicyURLKey = "kPersonalyNativeAdPrivacyPolicyURLKey"
    static let kPersonalyNativeAdPrivacyPolicyImageURLKey = "kPersonalyNativeAdPrivacyPolicyImageURLKey"

    override public func requestAd(withCustomEventInfo info: [AnyHashable : Any]!) {

        guard let appID = info["appId"] as? String else {

            print("Invalid setup. Use the appId parameter when configuring your network in the MoPub website.")
            return
        }

        guard let placementID = info["placementId"] as? String else {

            print("Invalid setup. Use the placementId parameter when configuring your network in the MoPub website.")
            return
        }

        Personaly.configure(withAppID: appID) { success, error in

            if let error = error {

                print("Failed to load Personaly interstitial: %@", error);
                self.delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: error)
            }
            else {

                let options = PersonalyNativeAdOptions()

                if let creativeType = info["creativeType"] as? String {

                    options.creativeType = creativeType.lowercased()
                }

                Personaly.precacheNativeAds(forPlacement: placementID, options: options, completion: { nativeAds, error in

                    if let error = error {

                        print("Failed to load Personaly interstitial: %@", error);
                        self.delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: error)

                    }
                    else {

                        if let nativeAd = nativeAds.first {

                            let adapter = PersonalyNativeAdAdapter(personalyNativeAd: nativeAd)
                            let moPubNativeAd = MPNativeAd(adAdapter: adapter)
                            self.delegate?.nativeCustomEvent(self, didLoad: moPubNativeAd)
                        }
                        else {

                            self.delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: nil)
                        }
                    }
                })
            }
        }
    }
}
