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

    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    var myInfo = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePic.layer.cornerRadius = 8
        self.profilePic.clipsToBounds = true
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String:Any]{
                
                
                let username = userDictionary["username"] as! String
                let email = userDictionary["email"] as! String
                let uid = userDictionary["userID"] as! String
                let pictures = userDictionary["Pictures"] as! [String]
                let total = userDictionary["rateTotal"] as! Double
                let times = userDictionary["timesRated"] as! Double
                let averageRate = total / times
                self.averageRateLabel.text = "Average Rate: \(averageRate)"
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
