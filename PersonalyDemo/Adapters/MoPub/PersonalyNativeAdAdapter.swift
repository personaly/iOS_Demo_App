//
//  PersonalyNativeAdAdapter.swift
//  PersonalyMoPubAdapter
//
//  Created by Mobexs on 11/16/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import Personaly
import MoPub

class PersonalyNativeAdAdapter: NSObject, MPNativeAdAdapter {

    var properties: [AnyHashable : Any]!
    var defaultActionURL: URL!
    var delegate: MPNativeAdAdapterDelegate!

    private let personalyNativeAd: PersonalyNativeAd
    private lazy var mediaView: PersonalyMediaView = {

        let mediaView = PersonalyMediaView()
        return mediaView
    }()

    init(personalyNativeAd: PersonalyNativeAd) {

        self.personalyNativeAd = personalyNativeAd

        self.properties = [kAdTitleKey: personalyNativeAd.appName,
                           kAdTextKey: personalyNativeAd.appDescription,
                           kAdIconImageKey: personalyNativeAd.appIconURL,
                           kAdCTATextKey: personalyNativeAd.callToActionText,
                           kAdStarRatingKey: personalyNativeAd.rating,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdReviewsCountKey: personalyNativeAd.reviewsCount,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdAppDeveloperKey: personalyNativeAd.appDeveloper,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdAppStoreIDKey: personalyNativeAd.storeAppID,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdAppStoreURLKey: personalyNativeAd.storeAppURL,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdCategoriesKey: personalyNativeAd.categories,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdPrivacyPolicyURLKey: personalyNativeAd.privacyPolicyURL,
                           PersonalyNativeCustomEvent.kPersonalyNativeAdPrivacyPolicyImageURLKey: personalyNativeAd.privacyPolicyImageURL
        ]

        for asset in personalyNativeAd.assets {

            if asset.type == "image" {

                self.properties[kAdMainImageKey] = asset.URL
                break
            }
        }

        if let url = URL(string: personalyNativeAd.trackingURL) {

            self.defaultActionURL = url
        }
    }

    func displayContent(for URL: URL!, rootViewController controller: UIViewController!) {

        self.delegate?.nativeAdWillLeaveApplication(from: self)
        UIApplication.shared.openURL(URL)
    }

    func mainMediaView() -> UIView! {

        self.mediaView.nativeAd = self.personalyNativeAd
        return self.mediaView
    }

    func trackClick() {

        Personaly.reportNativeAdClick(impressionID: self.personalyNativeAd.impressionID)

        if let nativeAdDidClick = self.delegate?.nativeAdDidClick {

            nativeAdDidClick((self))
        }
    }

    func willAttach(to view: UIView!) {

        if let nativeAdWillLogImpression = self.delegate?.nativeAdWillLogImpression {

            nativeAdWillLogImpression((self))
        }
        Personaly.reportNativeAdImpression(impressionID: self.personalyNativeAd.impressionID)
    }
}
