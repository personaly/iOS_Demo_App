//
//  PersonalyVideoAdNetworkAdapter.swift
//  PersonalyAdapters
//
//  Created by Mobexs on 11/20/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import GoogleMobileAds
import Personaly

@objc(PersonalyVideoAdNetworkAdapter)
public class PersonalyVideoAdNetworkAdapter: NSObject, GADMRewardBasedVideoAdNetworkAdapter, PersonalyRouterDelegate {

    private var connector: GADMRewardBasedVideoAdNetworkConnector
    private var appID: String?
    private var placementID: String?
    private var isConfigured: Bool = false
    private var isPrecached: Bool = false

    public required init!(rewardBasedVideoAdNetworkConnector connector: GADMRewardBasedVideoAdNetworkConnector!, credentials: [[AnyHashable : Any]]!) {

        self.connector = connector
        super.init()
    }

    public required init!(gadmAdNetworkConnector connector: GADMRewardBasedVideoAdNetworkConnector!) {

        self.connector = connector
        super.init()
    }

    public required init!(rewardBasedVideoAdNetworkConnector connector: GADMRewardBasedVideoAdNetworkConnector!) {

        self.connector = connector
        super.init()
    }

    public static func adapterVersion() -> String! {

        let bundleID = "com.personaly.PersonalyAdmobAdapter"
        if let version = Bundle(identifier: bundleID)?.infoDictionary?["CFBundleShortVersionString"] as? String {

            return version
        }
        return ""
    }

    public static func networkExtrasClass() -> GADAdNetworkExtras.Type! {

        return PersonalyAdMobNetworkExtras.self
    }

    public func setUp() {

        guard let serverParameterString = self.connector.credentials()[GADCustomEventParametersServer] as? String else {

            self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: PersonalyError.internalError(message: "Server parameters JSON is empty or invalid"))
            return
        }

        guard let serverParameterData = serverParameterString.data(using: .utf8) else {

            self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: PersonalyError.internalError(message: "Server parameters JSON is empty or invalid"))
            return
        }

        do {

            let json = try JSONSerialization.jsonObject(with: serverParameterData, options: []) as! Dictionary<String, Any>

            guard let appID = json["appId"] as? String else {

                self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: PersonalyError.internalError(message: "Server parameters JSON has no appId"))
                return
            }

            guard let placementID = json["placementId"] as? String else {

                self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: PersonalyError.internalError(message: "Server parameters JSON has no placementId"))
                return
            }

            self.appID = appID
            self.placementID = placementID
            self.isConfigured = false

            PersonalyRouter.shared.addDelegate(self)
            Personaly.configure(withAppID: appID) { success, error in }
        }
        catch (let error) {

            self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: error)
        }
    }

    public func requestRewardBasedVideoAd() {

        guard let placementID = self.placementID else {

            self.connector.adapter(self, didFailToLoadRewardBasedVideoAdwithError: nil)
            return
        }

        self.isPrecached = false
        Personaly.precacheCampaigns(forPlacement: placementID) { success, error in }
    }

    public func presentRewardBasedVideoAd(withRootViewController viewController: UIViewController!) {

        guard let placementID = self.placementID else {

            self.connector.adapter(self, didFailToLoadRewardBasedVideoAdwithError: nil)
            return
        }

        if Personaly.isCampaignReady(placementID: placementID) == true {

            self.connector.adapterDidOpenRewardBasedVideoAd(self)
            self.connector.adapterDidStartPlayingRewardBasedVideoAd(self)

            var serverParameter: PersonalyServerParameter?
            if let extras = self.connector.networkExtras() as? PersonalyAdMobNetworkExtras {

                serverParameter = extras.serverParameter
            }

            Personaly.showCampaign(forPlacement: placementID, serverParameter: serverParameter) { success, error in

                self.connector.adapterDidCloseRewardBasedVideoAd(self)
                if let error = error {

                    print(error.localizedDescription)
                }
            }
        }
        else {

            print("Personaly has no ads to show.")
        }
    }

    public func stopBeingDelegate() {

    }

    //MARK:- PersonalyRouterDelegate

    func didPrecache(forPlacement placementID: String) {

        if placementID == self.placementID,
            self.isPrecached == false {

            self.isPrecached = true
            self.connector.adapterDidReceiveRewardBasedVideoAd(self)
        }
    }

    func didFailPrecache(forPlacement placementID: String, error: Error?) {

        if placementID == self.placementID {

            if let error = error as? PersonalyError {

                if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
            }

            if self.isPrecached == false {

                self.isPrecached = true
                self.connector.adapter(self, didFailToLoadRewardBasedVideoAdwithError: error)
            }
        }
    }

    func didReceiveReward(forPlacement placementID: String, amount: Int) {

        if placementID == self.placementID {

            self.connector.adapterDidReceiveRewardBasedVideoAd(self)
        }
    }

    func didReceiveClick(forPlacement placementID: String) {

        if placementID == self.placementID {

            self.connector.adapterDidGetAdClick(self)
        }
    }

    func didConfigure() {

        if self.isConfigured == false {

            self.isConfigured = true
            self.connector.adapterDidSetUpRewardBasedVideoAd(self)
        }
    }

    func didFailConfigure(with error: Error?) {

        if let error = error as? PersonalyError {

            if error.errorCode == PersonalyError.functionInProgress.errorCode { return }
        }

        if self.isConfigured == false {

            self.isConfigured = true
            self.connector.adapter(self, didFailToSetUpRewardBasedVideoAdWithError: error)
        }
    }

    //MARK:- Clean

    deinit {

        PersonalyRouter.shared.removeDelegate(self)
    }
}
