//
//  ViewController.swift
//  PersonalyDemo
//
//  Created by Mobexs on 3/10/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import UIKit
import Personaly
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, PersonalyDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var appIDTextField: UITextField!
    @IBOutlet weak var userIDTestField: UITextField!
    @IBOutlet weak var serverParameterTextField: UITextField!
    @IBOutlet weak var campaignPlacementIDTextField: UITextField!
    @IBOutlet weak var rewardablePopupPlacementID2TextField: UITextField!
    @IBOutlet weak var rewardablePopupPlacementIDTextField: UITextField!
    @IBOutlet weak var offerWallPlacementIDTextField: UITextField!
    @IBOutlet weak var canShowPlacementIDTextField: UITextField!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nativePlacementIDTextField: UITextField!
    @IBOutlet weak var numberNativeAdsToPrecacheTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var nativeAds: [PersonalyNativeAd] = []

    override var prefersStatusBarHidden: Bool {

        return false
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        if let dict = Bundle.main.infoDictionary,
            let version = dict["CFBundleShortVersionString"] as? String{
            
            self.versionLabel.text = "v. \(version)"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationsHandler(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.notificationsHandler(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        //Personaly.delegate = self
    }

    //MAKR:- Notifications handler

    @objc func notificationsHandler(notification: Notification) {

        if notification.name == NSNotification.Name.UIKeyboardWillShow {

            if let userInfo = notification.userInfo {

                let rect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
                self.scrollView.contentInset = UIEdgeInsets(top: self.scrollView.contentInset.top,
                                                            left: self.scrollView.contentInset.left,
                                                            bottom: rect.size.height,
                                                            right: self.scrollView.contentInset.right)
            }
        }
        else if notification.name == NSNotification.Name.UIKeyboardWillHide {

            self.scrollView.contentInset = UIEdgeInsets(top: self.scrollView.contentInset.top,
                                                        left: self.scrollView.contentInset.left,
                                                        bottom: 0,
                                                        right: self.scrollView.contentInset.right)
        }
    }

    // MARK: - Actions

    @IBAction func configure(sender: Any) {

        guard let appID = self.appIDTextField.text,
            appID.characters.count > 0,
            let userID = self.userIDTestField.text,
            userID.characters.count > 0 else {

            self.showError(message: "Please input App ID and User ID")
            return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Configuring framework..."
        
        let params:[String: Any] = [Personaly.ageKey: 19,
                                    Personaly.userIDKey: userID,
                                    Personaly.genderKey: "male",
                                    Personaly.dateOfBirthdayKey: Date()]

        Personaly.configure(withAppID: appID, parameters: params, completion: { success, error in

            self.activityIndicatorView.stopAnimating()

            if success == true {

                self.statusLabel.text = "Framework is configured!"
            }
            else if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }

    @IBAction func precacheCampaign(sender: Any) {

        guard let placementID = self.campaignPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching campaign..."

        Personaly.precacheCampaigns(forPlacement: placementID) { success, error in

            self.activityIndicatorView.stopAnimating()

            if success == true {

                self.statusLabel.text = "Campaign is precached!"
            }
            else if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        }
    }

    @IBAction func showCampaign(sender: Any) {

        guard let placementID = self.campaignPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        let serverParameter = PersonalyServerParameter()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            serverParameter.parameters = ["clickId": serverParameterValue]
        }

        Personaly.showCampaign(forPlacement: placementID, serverParameter: serverParameter, completion: { success, error in

            if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }

    @IBAction func precacheCampaign2(sender: Any) {

        guard let placementID = self.rewardablePopupPlacementID2TextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching campaign..."

        Personaly.precacheCampaigns(forPlacement: placementID) { success, error in

            self.activityIndicatorView.stopAnimating()

            if success == true {

                self.statusLabel.text = "Campaign is precached!"
            }
            else if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        }
    }

    @IBAction func showCampaign2(sender: Any) {

        guard let placementID = self.rewardablePopupPlacementID2TextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        let serverParameter = PersonalyServerParameter()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            serverParameter.parameters = ["clickId": serverParameterValue]
        }

        Personaly.showCampaign(forPlacement: placementID, serverParameter: serverParameter, completion: { success, error in

            if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {
                    
                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }

    @IBAction func showOfferWall(sender: Any) {

        guard let placementID = self.offerWallPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        let serverParameter = PersonalyServerParameter()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            serverParameter.parameters = ["clickId": serverParameterValue]
        }

        Personaly.showOfferWall(forPlacement: placementID, serverParameter: serverParameter, completion: { success, error in

            if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }

    @IBAction func canShowForPlacement(sender: Any) {

        guard let placementID = self.canShowPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        self.activityIndicatorView.startAnimating()

        Personaly.canView(forPlacement: placementID) { success, error in

            self.activityIndicatorView.stopAnimating()

            if let error = error {

                self.statusLabel.text = error.localizedDescription
            }
            else {

                self.statusLabel.text = success == true ? "Can Show" : "Cannot show"
            }
        }
    }

    @IBAction func precachePopup(sender: Any) {

        guard let placementID = self.rewardablePopupPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        self.activityIndicatorView.startAnimating()
        self.statusLabel.text = "Precaching rewardable popup..."

        Personaly.precacheRewardablePopupTemplate { success, error in

            self.activityIndicatorView.stopAnimating()

            if success == true {

                self.statusLabel.text = "Popup is precached!"
            }
            else if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        }
    }

    @IBAction func showPopup(sender: Any) {

        guard let placementID = self.rewardablePopupPlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        let serverParameter = PersonalyServerParameter()
        if let serverParameterValue = self.serverParameterTextField.text,
            serverParameterValue.characters.count > 0 {

            serverParameter.parameters = ["clickId": serverParameterValue]
        }

        Personaly.showRewardablePopup(forPlacement: placementID, serverParameter: serverParameter, completion: { success, error in

            if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {
                    
                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }
    
    @IBAction func sendLog(sender: Any) {
        
        if MFMailComposeViewController.canSendMail() == true {
            
            let controller = MFMailComposeViewController()
            controller.setSubject("Personaly Log")
            controller.setMessageBody(Personaly.getLog(), isHTML: false)
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            
            self.statusLabel.text = "Can't send email. Set up email clinet."
        }
    }

    @IBAction func precacheNative(sender: Any) {

        guard let placementID = self.nativePlacementIDTextField.text,
            placementID.characters.count > 0 else {

                self.showError(message: "Please input Placement ID")
                return
        }

        self.statusLabel.text = "Precaching Native Ads..."
        self.activityIndicatorView.startAnimating()

        let options = PersonalyNativeAdOptions()
        options.shouldDownloadAssets = true

        if let numberString = self.numberNativeAdsToPrecacheTextField.text, let numberOfAdsToPrecache = Int(numberString) {

            options.numberOfAdsToPrecache = numberOfAdsToPrecache
            options.creativeType = "image"
        }

        Personaly.precacheNativeAds(forPlacement: placementID, options: options, completion: { nativeAds, error in

            self.activityIndicatorView.stopAnimating()
            if nativeAds.count > 0 {

                self.statusLabel.text = "Native Ad is precached!"
                self.nativeAds = nativeAds
                self.tableView.reloadData()
            }
            else if let error = error {

                if error is PersonalyError {

                    let error = error as! PersonalyError
                    self.statusLabel.text = error.localizedDescription
                }
                else {

                    self.statusLabel.text = error.localizedDescription
                }
            }
        })
    }

    //MARK:- MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK:- CampaignDelegate

    func didReceiveReward(forPlacement placementID: String, amount: Int) {

        print("didReceiveReward forPlacement: " + placementID + " amount: " + String(amount))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        label.backgroundColor = UIColor.white
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor.red.cgColor
        label.text = "Reward: " + String(amount) + " coins!"
        label.textAlignment = .center
        
        UIViewController.topMostViewController()?.view.addSubview(label)
        
        let dispatchTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            
            label.removeFromSuperview()
        }
    }
    
    func didPrecache(forPlacement placementID: String) {
        
        print("didPrecache forPlacement: " + placementID)
    }

    func didFailPrecache(forPlacement placementID: String, error: Error?) {

        var errorMessage = "N/A"
        if let error = error {

            errorMessage = error.localizedDescription
        }
        print("didFailPrecache forPlacement: \(placementID) withError: \(errorMessage)")
    }

    func didReceiveClick(forPlacement placementID: String) {

        print("didReceiveClick forPlacement: \(placementID)")
    }

    func didConfigure() {

    }

    func didFailConfigure(with error: Error?) {
        
    }

    //MARK:- UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    //MARK:- UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.nativeAds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "nativeAdCell", for: indexPath)

        if let nativeAdCell = cell as? NativeAdCell {

            let nativeAd = self.nativeAds[indexPath.row]
            let options = PersonalyMediaViewOptions()
            options.shouldAutoplayVideo = true
            options.shouldLoopVideo = true
            options.shouldMuteVideo = false

            let serverParameter = PersonalyServerParameter()
            if let serverParameterValue = self.serverParameterTextField.text,
                serverParameterValue.characters.count > 0 {

                serverParameter.parameters = ["clickId": serverParameterValue]
            }

            Personaly.populateNativeAdView(view: nativeAdCell.nativeAdView, with: nativeAd, options: [options, serverParameter], completion: { (success, error) in

            })
        }

        return cell
    }

    //MARK:- UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 320
    }

    //MARK:- Private functions

    private func showError(message: String) {

        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}

