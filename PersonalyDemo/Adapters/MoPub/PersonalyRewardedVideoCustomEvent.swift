//
//  PersonalyRewardedVideoCustomEvent.swift
//  MopubAdapterDemo
//
//  Created by Mobexs on 11/10/17.
//  Copyright © 2017 Persona.ly. All rights reserved.
//

import Personaly
import MoPub

@objc(PersonalyRewardedVideoCustomEvent)
public class PersonalyRewardedVideoCustomEvent: MPRewardedVideoCustomEvent, PersonalyRouterDelegate {

    private var placementID: String?
    private var isConfigured: Bool = false
    private var isPrecached: Bool = false

    //MARK: - PersonalyRewardedVideoCustomEvent Subclass Functions

    override public func requestRewardedVideo(withCustomEventInfo info: [AnyHashable : Any]!) {

        guard let appID = info["appId"] as? String else {

            print("Invalid setup. Use the appId parameter when configuring your network in the MoPub website.")
            return
        }

        guard let placementID = info["placementId"] as? String else {

            print("Invalid setup. Use the placementId parameter when configuring your network in the MoPub website.")
            return
        }

        self.placementID = placementID
        self.isConfigured = false
        self.isPrecached = false

        PersonalyRouter.shared.addDelegate(self)
        Personaly.configure(withAppID: appID) { success, error in }
    }

    override public func hasAdAvailable() -> Bool {

        if let placementID = self.placementID {

            return Personaly.isCampaignReady(placementID: placementID)
        }
        return false
    }

    override public func presentRewardedVideo(from viewController: UIViewController!) {

        guard let placementID = self.placementID else {

            self.delegate?.rewardedVideoDidFailToLoadAd(for: self, error: nil)
            return
        }

        if Personaly.isCampaignReady(placementID: placementID) == true {

            self.delegate?.rewardedVideoWillAppear(for: self)
            self.delegate?.rewardedVideoDidAppear(for: self)

            var serverParameter: PersonalyServerParameter?
            if let settings = self.delegate.instanceMediationSettings(for: PersonalyMoPubMediationSettings.self) as? PersonalyMoPubMediationSettings {

                serverParameter = settings.serverParameter
            }

            Personaly.showCampaign(forPlacement: placementID, serverParameter: serverParameter) { success, error in

                if let error = error {

                    print("Failed to show Personaly rewarded: %@", error);
                    self.delegate?.rewardedVideoDidFailToPlay(for: self, error: error)
                }

                self.delegate?.rewardedVideoWillDisappear(for: self)
                self.delegate?.rewardedVideoDidDisappear(for: self)
            }
        }
        else {

            print("Failed to show Personaly rewarded: Personaly now claims that there is no available ad.");
            self.delegate?.rewardedVideoDidFailToPlay(for: self, error: PersonalyError.noPrecachedDataToShow(message: nil))
        }
    }

    //MARK:- PersonalyRouterDelegate

    func didReceiveReward(forPlacement placementID: String, amount: Int) {

        if placementID == self.placementID {

            let reward = MPRewardedVideoReward(currencyAmount: NSNumber(value: amount))
            self.delegate?.rewardedVideoShouldRewardUser(for: self, reward: reward)
        }
    }

    func didPrecache(forPlacement placementID: String) {

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.delegate?.rewardedVideoDidLoadAd(for: self)
        }
    }

    func didFailPrecache(forPlacement placementID: String, error: Error?) {

        if let error = error as? PersonalyError {

            if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
        }

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.delegate?.rewardedVideoDidFailToLoadAd(for: self, error: error)
        }
    }

    func didReceiveClick(forPlacement placementID: String) {

        if placementID == self.placementID {

            self.delegate?.rewardedVideoDidReceiveTapEvent(for: self)
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
            self.delegate?.rewardedVideoDidFailToLoadAd(for: self, error: error)
        }
    }

    //MARK:- Clean

    deinit {

        PersonalyRouter.shared.removeDelegate(self)
    }
}
