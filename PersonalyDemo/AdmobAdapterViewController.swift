//
//  AdmobAdapterViewController.swift
//  PersonalyDemo
//
//  Created by Mobexs on 11/20/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Personaly

class AdmobAdapterViewController: UIViewController, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var appIDTestField: UITextField!
    @IBOutlet weak var interstitialAdUnitIDTestField: UITextField!
    @IBOutlet weak var rewardedAdUnitIDTestField: UITextField!
    @IBOutlet weak var serverParameterTextField: UITextField!
    
    var interstitial: GADInterstitial?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Actions

    @IBAction func back(sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func configure(sender: Any) {

        guard let appID = self.appIDTestField.text,
            appID.characters.count > 0 else {

                self.showError(message: "Please input App ID")
                return
        }

        GADMobileAds.configure(withApplicationID: appID)

        self.statusLabel.text = "Admob is configured."
    }

    @IBAction func precacheInterstitial(sender: Any) {

        guard let unitID = self.interstitialAdUnitIDTestField.text,
            unitID.characters.count > 0 else {

                self.showError(message: "Please input Ad Unit ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching Admob Interstitial Ad..."

        let extras = GADCustomEventExtras()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            extras.setExtras(["clickId": serverParameterValue], forLabel: "InterstitialCustomEvent")
        }

        let request = GADRequest()
        request.register(extras)

        let interstitial = GADInterstitial(adUnitID: unitID)
        interstitial.delegate = self
        interstitial.load(request)
        self.interstitial = interstitial
    }

    @IBAction func precacheRewarded(sender: Any) {

        guard let unitID = self.rewardedAdUnitIDTestField.text,
            unitID.characters.count > 0 else {

                self.showError(message: "Please input Ad Unit ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching Admob Rewarded Ad..."

        let serverParameter = PersonalyServerParameter()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            serverParameter.parameters = ["clickId": serverParameterValue]
        }

        let extras = PersonalyAdMobNetworkExtras()
        extras.serverParameter = serverParameter

        let request = GADRequest()
        request.register(extras)

        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: unitID)
    }

    //MARK:- GADInterstitialDelegate

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Admob Interstitial Ad is precached!"

        if let interstitial = self.interstitial {

            interstitial.present(fromRootViewController: self)
        }
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Failed to precache Admob Interstitial Ad.\n" + error.localizedDescription
    }

    //MARK:- GADRewardBasedVideoAdDelegate

    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Admob Rewarded Ad is precached!"
        GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
    }

    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Failed to precache Admob Rewarded Ad.\n" + error.localizedDescription
    }

    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        label.backgroundColor = UIColor.white
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor.red.cgColor
        label.text = "Reward: \(reward.amount) coins!"
        label.textAlignment = .center

        UIViewController.topMostViewController()?.view.addSubview(label)

        let dispatchTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {

            label.removeFromSuperview()
        }
    }

    //MARK:- Private functions

    private func showError(message: String) {

        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}
