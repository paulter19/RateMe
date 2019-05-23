//
//  NextSignUpViewController.swift
//  RateMe
//
//  Created by Paul Ter on 5/15/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds


class NextSignUpViewController: UIViewController,GADBannerViewDelegate {
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var bio: UITextView!
    
    @IBOutlet weak var instagramTextfield: UITextField!
    
    
    var gender = "m"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let view = GADBannerView()
        view.frame = CGRect(x: 0, y: self.view.frame.maxY - 50, width: 320, height: 50)
        view.delegate = self
        view.rootViewController = self
        view.adUnitID = "ca-app-pub-1666211014421581/8054549109"
        view.load(GADRequest())
        self.view.addSubview(view)

        // Do any additional setup after loading the view.
    }
    @IBAction func nextClicked(_ sender: Any) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["bio":self.bio.text,"instagram":self.instagramTextfield.text,"gender":self.gender])
        
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
        self.present(home, animated: false, completion: nil)
        
        
        
        
    }
    @IBAction func maleClicked(_ sender: Any) {
        self.maleButton.backgroundColor = .blue
        self.maleButton.setTitleColor(.white, for: .normal)
        
        self.femaleButton.backgroundColor = .clear
        self.femaleButton.setTitleColor(.blue, for: .normal)
        self.gender = "m"
        
    }
    @IBAction func femaleClicked(_ sender: Any) {
        self.femaleButton.backgroundColor = .blue
        self.femaleButton.setTitleColor(.white, for: .normal)
        
        self.maleButton.backgroundColor = .clear
        self.maleButton.setTitleColor(.blue, for: .normal)
        self.gender = "f"

        
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextSignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismiss keyboard")
        view.endEditing(true)
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    

   

}
