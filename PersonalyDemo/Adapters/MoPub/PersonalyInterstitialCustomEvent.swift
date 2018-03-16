//
//  PersonalyInterstitialCustomEvent.swift
//  PersonalyMopubAdapter
//
//  Created by Sergei Kvasov on 11/9/17.
//  Copyright © 2017 Persona.ly. All rights reserved.
//

import Personaly
import MoPub

@objc(PersonalyInterstitialCustomEvent)
public class PersonalyInterstitialCustomEvent: MPInterstitialCustomEvent, PersonalyRouterDelegate {

    private var placementID: String?
    private var isConfigured: Bool = false
    private var isPrecached: Bool = false

    //MARK: - MPInterstitialCustomEvent Subclass Functions

    override public func requestInterstitial(withCustomEventInfo info: [AnyHashable : Any]!) {

        guard let appID = info["appId"] as? String else {

            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: nil)
            return
        }

        guard let placementID = info["placementId"] as? String else {

            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: nil)
            return
        }

        self.placementID = placementID
        self.isConfigured = false
        self.isPrecached = false
        PersonalyRouter.shared.addDelegate(self)

        Personaly.configure(withAppID: appID) { success, error in }
    }

    override public func showInterstitial(fromRootViewController rootViewController: UIViewController!) {

        guard let placementID = self.placementID else {

            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: nil)
            return
        }

        if Personaly.isCampaignReady(placementID: placementID) == true {

            self.delegate?.interstitialCustomEventWillAppear(self)
            self.delegate?.interstitialCustomEventDidAppear(self)

            Personaly.showCampaign(forPlacement: placementID) { success, error in

                if let error = error {

                    print("Failed to show Personaly interstitial: %@", error);
                    self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: error)
                }

                self.delegate?.interstitialCustomEventWillDisappear(self)
                self.delegate?.interstitialCustomEventDidDisappear(self)
            }
        }
        else {

            print("Failed to show Personaly interstitial: Personaly now claims that there is no available ad.");
            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: PersonalyError.noPrecachedDataToShow(message: nil))
        }
    }

    //MARK:- PersonalyRouterDelegate

    func didPrecache(forPlacement placementID: String) {

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.delegate?.interstitialCustomEvent(self, didLoadAd: nil)
        }
    }

    func didFailPrecache(forPlacement placementID: String, error: Error?) {

        if let error = error as? PersonalyError {

            if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
        }

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: error)
        }
    }

    func didConfigure() {

        if let placementID = self.placementID,
            self.isConfigured == false {

            self.isConfigured = true
            Personaly.precacheCampaigns(forPlacement: placementID, completion: { success, error in })
        }
    }

    func didFailConfigure(with error: Error?) {

        if let error = error as? PersonalyError {

            if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
        }

        if self.isConfigured == false {

            self.isConfigured = true
            self.delegate?.interstitialCustomEvent(self, didFailToLoadAdWithError: error)
        }
    }

    func didReceiveReward(forPlacement placementID: String, amount: Int) { }
    func didReceiveClick(forPlacement placementID: String) { }

    //MARK:- Clean

    deinit {

        PersonalyRouter.shared.removeDelegate(self)
    }

}
