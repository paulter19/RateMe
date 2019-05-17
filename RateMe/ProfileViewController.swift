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

class ProfileViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
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
                self.averageRateLabel.text = "Average Rate: \(String(format: "%.2f", averageRate))"
                self.usernameTextLabel.text = username
                
                
                self.myInfo = User(username: username, email: email, uid: uid, pics: pictures)
                
                if(userDictionary["peopleIRated"] != nil){
                    let irated = userDictionary["peopleIRated"] as! [String]
                    self.myInfo.setRates(rates: irated)
                }
                self.loadImage(urlString: self.myInfo.getPictures()[0])
                
            }
            
        }, withCancel: nil)
        
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
        }else{
            self.slider.isHidden = false
            self.rateLabel.isHidden = false
            self.rateButton.isHidden = false
        }
        
        

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
