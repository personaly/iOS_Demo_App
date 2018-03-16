//
//  MoPubAdapterViewController.swift
//  PersonalyDemo
//
//  Created by Mobexs on 11/14/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit
import MoPub
import Personaly

class MoPubAdapterViewController: UIViewController, MPInterstitialAdControllerDelegate, MPRewardedVideoAdManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var serverParameterTextField: UITextField!
    @IBOutlet weak var interstitialAdUnitIDTestField: UITextField!
    @IBOutlet weak var rewardedAdUnitIDTestField: UITextField!
    @IBOutlet weak var nativeAdUnitIDTestField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var rewardedManager: MPRewardedVideoAdManager?
    var interstitialController: MPInterstitialAdController?
    var nativePlacer: MPTableViewAdPlacer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.mp_setDelegate(self)
        self.tableView.mp_setDataSource(self)
    }

    // MARK: - Actions

    @IBAction func back(sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func precacheInterstitial(sender: Any) {

        guard let unitID = self.interstitialAdUnitIDTestField.text,
            unitID.characters.count > 0 else {

                self.showError(message: "Please input Ad Unit ID")
                return
        }

        if let controller = MPInterstitialAdController(forAdUnitId: unitID) {

            self.activityIndicatorView.startAnimating()
            self.statusLabel.text = "Precaching MoPub Interstitial Ad..."

            controller.delegate = self
            controller.loadAd()
            self.interstitialController = controller
        }
    }

    @IBAction func precacheRewarded(sender: Any) {

        guard let unitID = self.rewardedAdUnitIDTestField.text,
            unitID.characters.count > 0 else {

                self.showError(message: "Please input Ad Unit ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching MoPub Rewarded Ad..."

        if let manager = MPRewardedVideoAdManager(adUnitID: unitID, delegate: self) {

            let serverParameter = PersonalyServerParameter()
            if let serverParameterValue = self.serverParameterTextField.text,
                serverParameterValue.characters.count > 0 {

                serverParameter.parameters = ["clickId": serverParameterValue]
            }

            let settings = PersonalyMoPubMediationSettings()
            settings.serverParameter = serverParameter

            manager.mediationSettings = [settings]
            manager.loadRewardedVideoAd(withKeywords: nil, location: nil, customerId: nil)
            self.rewardedManager = manager
        }
    }

    @IBAction func precacheNative(sender: Any) {

        guard let unitID = self.nativeAdUnitIDTestField.text,
            unitID.characters.count > 0 else {

                self.showError(message: "Please input Ad Unit ID")
                return
        }

        self.statusLabel.text = "Precaching MoPub Native Ad..."

        let targeting = MPNativeAdRequestTargeting()
        targeting.desiredAssets = [kAdTitleKey, kAdTextKey, kAdIconImageKey, kAdCTATextKey, kVideoConfigKey]
        targeting.location = CLLocation(latitude: 37.7793, longitude: -122.4175)

        let settings = MPStaticNativeAdRendererSettings()
        settings.renderingViewClass = MoPubNativeAdView.self
        settings.viewSizeHandler = { maximumWidth in

            return CGSize(width: 280, height: 300)
        }

        if let config = MPStaticNativeAdRenderer.rendererConfiguration(with: settings) {

            config.supportedCustomEvents.append("PersonalyNativeCustomEvent")

            if let placer = MPTableViewAdPlacer(tableView: self.tableView, viewController: self, rendererConfigurations: [config]) {

                placer.loadAds(forAdUnitID: unitID, targeting: targeting)
                self.nativePlacer = placer
            }
        }
    }

    //MARK:- UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.mp_dequeueReusableCell(withIdentifier: "nativeAdCell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    //MARK:- MPInterstitialAdControllerDelegate

    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "MoPub Interstitial Ad is precached!"

        interstitial.show(from: self)
    }

    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Failed to precache MoPub Interstitial Ad."
    }

    //MARK:- MPRewardedVideoAdManagerDelegate

    func rewardedVideoDidLoad(for manager: MPRewardedVideoAdManager!) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "MoPub Rewarded Ad is precached!"

        manager.presentRewardedVideoAd(from: self, with: manager.selectedReward, customData: nil)
    }

    func rewardedVideoDidFailToLoad(for manager: MPRewardedVideoAdManager!, error: Error!) {

        self.activityIndicatorView.stopAnimating()
        self.statusLabel.text = "Failed to precache MoPub Rewarded Ad.\n" + error.localizedDescription
    }

    func rewardedVideoWillAppear(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoDidExpire(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoDidFailToPlay(for manager: MPRewardedVideoAdManager!, error: Error!) { }
    func rewardedVideoDidAppear(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoWillDisappear(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoDidDisappear(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoDidReceiveTapEvent(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoWillLeaveApplication(for manager: MPRewardedVideoAdManager!) { }
    func rewardedVideoShouldRewardUser(for manager: MPRewardedVideoAdManager!, reward: MPRewardedVideoReward!) {

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
