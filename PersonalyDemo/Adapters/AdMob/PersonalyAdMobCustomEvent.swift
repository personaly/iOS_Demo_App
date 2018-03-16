//
//  PersonalyAdmobCustomEvent.swift
//  PersonalyAdmobAdapter
//
//  Created by Mobexs on 11/20/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import GoogleMobileAds
import Personaly

@objc(PersonalyAdMobCustomEvent)
public class PersonalyAdMobCustomEvent: NSObject, GADCustomEventInterstitial, PersonalyRouterDelegate {

    public var delegate: GADCustomEventInterstitialDelegate?

    private var placementID: String?
    private let serverParameter = PersonalyServerParameter()
    private var isConfigured: Bool = false
    private var isPrecached: Bool = false

    public func requestAd(withParameter serverParameter: String?, label serverLabel: String?, request: GADCustomEventRequest) {

        guard let serverParameterData = serverParameter?.data(using: .utf8) else {

            self.delegate?.customEventInterstitial(self, didFailAd: PersonalyError.internalError(message: "Server parameters JSON is empty or invalid"))
            return
        }

        do {

            let json = try JSONSerialization.jsonObject(with: serverParameterData, options: []) as! Dictionary<String, Any>

            guard let appID = json["appId"] as? String else {

                self.delegate?.customEventInterstitial(self, didFailAd: PersonalyError.internalError(message: "Server parameters JSON has no appId"))
                return
            }

            guard let placementID = json["placementId"] as? String else {

                self.delegate?.customEventInterstitial(self, didFailAd: PersonalyError.internalError(message: "Server parameters JSON has no placementId"))
                return
            }

            self.placementID = placementID
            self.isConfigured = false
            self.isPrecached = false
            
            if let parameters = request.additionalParameters as? [String: String] {

                self.serverParameter.parameters = parameters
            }

            PersonalyRouter.shared.addDelegate(self)
            Personaly.configure(withAppID: appID, completion: { success, error in })
        }
        catch (let error) {

            self.delegate?.customEventInterstitial(self, didFailAd: error)
        }
    }

    public func present(fromRootViewController rootViewController: UIViewController) {

        guard let placementID = self.placementID else {

            self.delegate?.customEventInterstitial(self, didFailAd: nil)
            return
        }

        self.delegate?.customEventInterstitialWillPresent(self)

        Personaly.showCampaign(forPlacement: placementID, serverParameter: self.serverParameter, completion: { success, error in

            self.delegate?.customEventInterstitialWillDismiss(self)
            self.delegate?.customEventInterstitialDidDismiss(self)

            if let error = error {

                self.delegate?.customEventInterstitial(self, didFailAd: error)
            }
        })
    }

    //MARK:- PersonalyRouterDelegate

    func didPrecache(forPlacement placementID: String) {

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.delegate?.customEventInterstitialDidReceiveAd(self)
        }
    }

    func didFailPrecache(forPlacement placementID: String, error: Error?) {

        if placementID == self.placementID {

            if let error = error as? PersonalyError {

                if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
            }

            if self.isPrecached == false {

                self.isPrecached = true
                self.delegate?.customEventInterstitial(self, didFailAd: error)
            }
        }
    }

    func didReceiveReward(forPlacement placementID: String, amount: Int) {

    }

    func didReceiveClick(forPlacement placementID: String) {

        if placementID == self.placementID {

            self.delegate?.customEventInterstitialWasClicked(self)
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
            self.delegate?.customEventInterstitial(self, didFailAd: error)
        }
    }

    //MARK:- Clean

    deinit {

        PersonalyRouter.shared.removeDelegate(self)
    }
}
