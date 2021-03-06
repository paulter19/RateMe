//
//  SignUpViewController.swift
//  RateMe
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleMobileAds


class SignUpViewController: UIViewController,GADBannerViewDelegate {
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    var profileUpload = UIImage(named: "default")
    var changedProfilePic = false
    
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
    @IBAction func signUpPressed(_ sender: Any) {
        
        if(self.emailTextfield.text?.count ?? 0 <= 4 || self.usernameTextfield.text?.count ?? 0 <= 4 || self.passwordTextfield.text?.count ?? 0 <= 4){
            
            let alertController = UIAlertController(title: "Invalid Signup", message: "All fields should be 4 characters or more", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            
            return
            
        }
        if(changedProfilePic == false){
            
            
            let alertController = UIAlertController(title: " Choose a profile picture", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        
        
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            self.signUpButton.isEnabled = false

            if(error == nil){
                
                let uid = user?.user.uid
                let randomString = UUID().uuidString


                let storRef = Storage.storage().reference().child("ProfilePics").child(uid!).child(randomString)

                
                if let uploadData = self.profileUpload?.jpegData(compressionQuality: 0.6){
                    storRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        storRef.downloadURL(completion: { (url, error) in
                            if(error != nil){
                                return
                            }
                            
                            let username = self.usernameTextfield.text?.lowercased()
                            let email = self.emailTextfield.text?.lowercased()
                            let dref = Database.database().reference().child("Users").child((user?.user.uid)!).setValue(["username":username,"email":email,"userID":uid,"Pictures":[url?.absoluteString],"rateTotal":10,"timesRated":1,"peopleIRated":[username],"visibility":"on"])
                            
                            print("going to that next screen")
                            let next = self.storyboard?.instantiateViewController(withIdentifier: "NextSignUp") as! NextSignUpViewController
                            self.present(next, animated: false, completion: nil)
                            
                            
                            
                            
                        })
                    })
                }

                
                
                
                
            }else{
                let alertController = UIAlertController(title: "Invalid Signup", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.signUpButton.isEnabled = true

            }
        }
        
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismiss keyboard")
        view.endEditing(true)
        
    }
    @IBAction func chooseProfilePic(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SignUpViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        self.changedProfilePic = true
        if let originalImage = info["UIImagePickerControllerEditedImage"]{
            print("edited image")
            self.profilePic.image = originalImage as? UIImage
            self.profileUpload = originalImage as? UIImage
            dismiss(animated: true, completion: nil)
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]  {
            print("original image")
            self.profilePic.image = originalImage as? UIImage
            self.profileUpload = originalImage as? UIImage
            dismiss(animated: true, completion: nil)
            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("dismissed image picker")
        dismiss(animated: true, completion: nil)
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





fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
}
