//
//  MoPubNativeAdView.swift
//  PersonalyDemo
//
//  Created by Mobexs on 11/15/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit
import MoPub
import Personaly

class MoPubNativeAdView: UIView, MPNativeAdRendering {

    @IBOutlet public weak var iconImageView: UIImageView?
    @IBOutlet public weak var appNameLabel: UILabel?
    @IBOutlet public weak var appDescriptionLabel: UILabel?
    @IBOutlet public weak var callToActionLabel: UILabel?
    @IBOutlet public weak var mainImageView: UIImageView?
    @IBOutlet public weak var privacyImageView: UIImageView?

    func nativeTitleTextLabel() -> UILabel! {

        return self.appNameLabel
    }

    func nativeMainTextLabel() -> UILabel! {

        return self.appDescriptionLabel
    }

    func nativeIconImageView() -> UIImageView! {

        return self.iconImageView
    }

    func nativeMainImageView() -> UIImageView! {

        return self.mainImageView
    }

    func nativeCallToActionTextLabel() -> UILabel! {

        return self.callToActionLabel
    }

    func nativePrivacyInformationIconImageView() -> UIImageView! {

        return self.privacyImageView
    }

    static func nibForAd() -> UINib! {

        return UINib.init(nibName: "MoPubNativeAdView", bundle: Bundle.main)
    }
}
