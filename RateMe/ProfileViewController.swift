//
//  ProfileViewController.swift
//  RateMe
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds
import FirebaseStorage


class ProfileViewController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    var cameFromSearch = false
    var myInfo = User()
    var searchInfo = User()
    
    override func viewWillAppear(_ animated: Bool) {
       print("view will")
        self.profilePic.layer.cornerRadius = 8
        self.profilePic.clipsToBounds = true
        
        if(cameFromSearch){
            sleep(1)

        
            print("its true")
            return
            
        }else{
            print("its false")
        }
        
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String:Any]{
                
                
                let username = userDictionary["username"] as! String
                let email = userDictionary["email"] as! String
                let uid = userDictionary["userID"] as! String
                let pictures = userDictionary["Pictures"] as! [String]
                let total = userDictionary["rateTotal"] as! Double
                let times = userDictionary["timesRated"] as! Double
                let averageRate = total / times
                let visibility = userDictionary["visibility"] as! String
                self.averageRateLabel.text = "Average Rate: \(String(format: "%.2f", averageRate))"
                self.usernameTextLabel.text = username
                
                var user = User(username: username, email: email, uid: uid, pics: pictures)
                user.setVisibility(visibility: visibility)
                self.myInfo = user
                
                if(userDictionary["peopleIRated"] != nil){
                    let irated = userDictionary["peopleIRated"] as! [String]
                    self.myInfo.setRates(rates: irated)
                }
                self.loadImage(urlString: self.myInfo.getPictures()[0])
                
            }
            
        }, withCancel: nil)
        
        let view = GADBannerView()
        view.frame = CGRect(x: 0, y: self.view.frame.maxY - 50, width: 320, height: 50)
        view.delegate = self
        view.rootViewController = self
        view.adUnitID = "ca-app-pub-1666211014421581/8054549109"
        view.load(GADRequest())
        self.view.addSubview(view)

        
    }
    
    @IBAction func addImagePressed(_ sender: Any) {
        
    }
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let login = self.storyboard?.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            self.present(login, animated: false, completion: nil
            )
        }catch{
            
        }
    }
    
    func setUpSearchedProfile(){
        
        print("setting up")

        self.usernameTextLabel.text = nil
        self.averageRateLabel.text = ""
        self.profilePic.image = nil
        

        loadImage(urlString: searchInfo.getPictures()[0])
        print("username should be \(searchInfo.getUsername())")
        self.usernameTextLabel.text = searchInfo.getUsername()
        let times = Double(searchInfo.getTimesRated() )
        let total = Double(searchInfo.getTotalRate())
        let averageRate = total / times
        self.averageRateLabel.text = "Average Rate: \(String(format: "%.2f",averageRate))"
        
        if(self.myInfo.getRates().contains(self.searchInfo.getUsername())){
            let alert = UIAlertController(title: "Already Rated", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }else if(self.searchInfo.getVisibility() == "off"){
            let alert = UIAlertController(title: "This user turn off their abilility to be rated", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alert, animated: false, completion: nil)
            
            
        }else if(self.myInfo.getUsername() == self.searchInfo.getUsername()){
            print("this is your profile")
            
            
        }else{
            self.slider.isHidden = false
            self.rateLabel.isHidden = false
            self.rateButton.isHidden = false
        }
        
        self.settingsButton.isHidden = true

    }
    
    func loadImage(urlString:String){
        
        let url = URL(string: urlString)
        if(url == nil){
            print("url is empty")
            return
        }
        
        print("url is \(url)")
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("Theres an error: " + error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    self.profilePic.image = downloadedImage
                    
                    
                    
                }
            }
        }).resume()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let index = (Int)(slider!.value + 0.5);
        slider?.setValue((Float)(index), animated: false)
        self.rateLabel.text = "\(index)"
        
    }
    @IBAction func rateButtonPressed(_ sender: Any) {
        if(self.myInfo.getRates() == nil || self.myInfo.getRates().count == 0){
            let justRatedUsername = self.searchInfo.getUsername()
            let rates = [justRatedUsername]
        }else{
            let justRatedUsername = self.searchInfo.getUsername()
            var rates = self.myInfo.getRates()
            rates.append(justRatedUsername)
            Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["peopleIRated":rates])
            
            
        }
        
        ratePerson(person: self.searchInfo, amount: Int(self.slider!.value))
        let alert = UIAlertController(title: "Rated", message: "\(self.slider.value)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        self.present(alert, animated: false, completion: nil)
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(home!, animated: false, completion: nil)
        
    }
    
    
    func ratePerson(person: User, amount: Int){
        var timeRated = 1
        var rateTotal = 10
        Database.database().reference().child("Users").child(person.getUid()).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                timeRated = dictionary["timesRated"] as! Int
                rateTotal = dictionary["rateTotal"] as! Int
                
                
                timeRated = timeRated + 1
                rateTotal = rateTotal + amount
                
                var ratedBy = [String:Any]()
                
                if(dictionary["ratedBy"] != nil){
                    ratedBy = dictionary["ratedBy"] as! [String:Any]
                    ratedBy.updateValue(amount, forKey: self.myInfo.getUsername())
                    
                }else{
                    
                    ratedBy.updateValue(amount, forKey: self.myInfo.getUsername())
                    
                }
                
                
                Database.database().reference().child("Users").child(person.getUid()).updateChildValues(["timesRated":timeRated,"rateTotal":rateTotal,"ratedBy":ratedBy])
            }
        }
        
        
        
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
    @IBAction func settingsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Settings", message: "", preferredStyle: .alert)
        
        var title = ""
        if(self.myInfo.getVisibility() == "off"){
            title = "Turn visibility on"
            print("just turned on")
        }else{
            title = "Turn visibility off"
            print("just turned off")

        }
        
        print("visibility is \(self.myInfo.getVisibility())")
        print("title is \(title)")
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            if(self.myInfo.getVisibility() == "off"){
                Database.database().reference().child("Users").child(self.myInfo.getUid()).updateChildValues(["visibility":"on"])
            }else{
                Database.database().reference().child("Users").child(self.myInfo.getUid()).updateChildValues(["visibility":"off"])

            }
        }))
        
        alert.addAction(UIAlertAction(title: "Change profile picture", style: .default, handler: { (action) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
           self.present(picker, animated: true, completion: nil)
        }))
        
        
    
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            do{
                try Auth.auth().signOut()
                let login = self.storyboard?.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
                self.present(login, animated: false, completion: nil
                )
            }catch{
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            print("cancel pressed")
        }))
        self.present(alert, animated: true, completion: nil)
        
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
extension ProfileViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let originalImage = info["UIImagePickerControllerEditedImage"]{
            print("edited image")
            self.profilePic.image = originalImage as? UIImage
            uploadImage(image: originalImage as! UIImage)
            
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]  {
            print("original image")
            self.profilePic.image = originalImage as? UIImage
            uploadImage(image: originalImage as! UIImage)
            

            
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("dismissed image picker")
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage){
        let storRef = Storage.storage().reference().child("ProfilePics").child(self.myInfo.getUid()).child("profilePic")
        if let uploadData = image.jpegData(compressionQuality: 0.6){
            storRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                storRef.downloadURL(completion: { (url, error) in
                    if(error != nil){
                        self.dismiss(animated: true, completion: nil)

                        return
                    }
                    
                    Database.database().reference().child("Users").child(self.myInfo.getUid()).updateChildValues(["Pictures":[url?.absoluteString]])
                    
                    self.dismiss(animated: true, completion: nil)

                    
                    
                    
                    
                })
            })
        }

    }
  
    
    
    
    
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
}
