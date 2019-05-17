//
//  ViewController.swift
//  RateMe
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var ratedEveryoneMessage: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var originalFrame:CGRect?
    var count = 0
    var myInfo = User()
    var peopleToRate = [User]()
    
   
    override func viewWillAppear(_ animated: Bool) {
        if(Auth.auth().currentUser != nil){
        getMyInfo()
        getUsers()
        }else{
            let signin = (self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!
            self.present(signin, animated: false, completion: nil)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser == nil){
            let signin = (self.storyboard?.instantiateViewController(withIdentifier: "SignIn"))!
            self.present(signin, animated: false, completion: nil)
           
        }
        if(self.peopleToRate == nil || self.peopleToRate.count == 0){
           self.slider.isHidden = true
            self.rateButton.isHidden = true
            self.ratedEveryoneMessage.isHidden = false
            //self.imageView.image = nil
            self.rateLabel.isHidden = true
            self.usernameLabel.isHidden = true
            self.skipButton.isHidden = true
            
            
        }else{
            print("not zero")
            let person = self.peopleToRate[0]
            let pictures = person.getPictures()
            let firstPicUrl = pictures[0]
            let rateTotal  = Double(person.getTotalRate())
            let timesRated = Double(person.getTimesRated())
            let averageRate = rateTotal/timesRated
            self.loadImage(urlString: firstPicUrl)
            self.usernameLabel.text = "\(person.getUsername())   Average Rate: \(String(format: "%.2f", averageRate))"
            self.ratedEveryoneMessage.isHidden = true
            self.slider.isHidden = false
            self.rateButton.isHidden = false
            self.rateLabel.isHidden = false
            self.usernameLabel.isHidden = false
            self.skipButton.isHidden = false

            
            self.originalFrame = self.imageView.frame


            

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(self.imageView == nil || self.rateButton == nil){
            return
        }
        self.imageView.layer.cornerRadius = 8
        self.imageView.clipsToBounds = true
        
        self.rateButton.layer.cornerRadius = 8
        self.rateButton.clipsToBounds = true
        
       // self.rateLabel.layer.cornerRadius = self.rateLabel.frame.width / 2
        //self.rateLabel.clipsToBounds = true
        
        
    
     }
    
    func getMyInfo(){
        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String:Any]{
                
                    print("I am ")
                    print(userDictionary["username"] as! String)
                    print("........")
                
                    let username = userDictionary["username"] as! String
                let email = userDictionary["email"] as! String
                let uid = userDictionary["userID"] as! String
                let pictures = userDictionary["Pictures"] as! [String]
                
                

                
                self.myInfo = User(username: username, email: email, uid: uid, pics: pictures)
                
                if(userDictionary["peopleIRated"] != nil){
                    let irated = userDictionary["peopleIRated"] as! [String]
                    self.myInfo.setRates(rates: irated)
                }
                
            }
            
        }, withCancel: nil)
        
    }
    
    func getUsers(){
        Database.database().reference().child("Users").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                for d in dictionary.values{
                    let userDictionary = d as! [String:Any]
                    let username = userDictionary["username"] as! String
                    let email = userDictionary["email"] as! String
                    let pictures = userDictionary["Pictures"] as! [String]
                    let uid = userDictionary["userID"] as! String
                    let timesRated = userDictionary["timesRated"] as! Int
                    let totalRate = userDictionary["rateTotal"] as! Int


                    print(username)
                    
                    if(self.myInfo.getRates().contains(username)){
                        print("skip already rated")
                        
                    }else{
                        print("not yet rated")
                       let theUser =  User(username: username, email: email, uid: uid, pics: pictures)
                        
                        theUser.setTotalRate(amount: totalRate)
                        theUser.setTimesRated(amount: timesRated)
                        
                        if(userDictionary["peopleIRated"] != nil){
                            let irated = userDictionary["peopleIRated"] as! [String]
                            theUser.setRates(rates: irated)
                        }
                        self.peopleToRate.append(theUser)
                        
                       

                        print("User count is \(self.peopleToRate.count)")
                        self.viewDidAppear(false)

                    }// end else
                }//end for
            }// end if let
        }//end database
    }//end getusers
    
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
                    self.imageView.image = downloadedImage
                    
                    
                    
                }
            }
        }).resume()
    }
    
    @IBAction func skipPressed(_ sender: Any) {
        if(self.myInfo.getRates() == nil || self.myInfo.getRates().count == 0){
            let justRatedUsername = self.peopleToRate[count].getUsername()
            let rates = [justRatedUsername]
        }else{
            let justRatedUsername = self.peopleToRate[count].getUsername()
            var rates = self.myInfo.getRates()
            rates.append(justRatedUsername)
            Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["peopleIRated":rates])
            
            
            
        }
        
        let home = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(home!, animated: false, completion: nil)
        
        
    }
    
    
    @IBAction func slideChanged(_ sender: Any) {
        
        let index = (Int)(slider!.value + 0.5);
       
        
        
        slider?.setValue((Float)(index), animated: false)
        self.rateLabel.text = "\(index)"
    }
    @IBAction func rateButtonPressed(_ sender: Any) {
        if(self.peopleToRate.count == 0){
            print("rated everyone")
            return
        }
        
        if(self.myInfo.getRates() == nil || self.myInfo.getRates().count == 0){
            let justRatedUsername = self.peopleToRate[count].getUsername()
            let rates = [justRatedUsername]
        }else{
            let justRatedUsername = self.peopleToRate[count].getUsername()
            var rates = self.myInfo.getRates()
            rates.append(justRatedUsername)
            Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["peopleIRated":rates])
            
            
        }
        
        ratePerson(person: self.peopleToRate[count], amount: Int(self.slider!.value))
        
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
    @IBAction func moveImageGesture(_ sender: UIPanGestureRecognizer) {
        
        let view = sender.view!
        let point = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + point.x, y: view.center.y)
        
        if(view.center.x < 0 - self.view.center.x){
            view.isHidden = true

            nextPic()
            sender.state = UIGestureRecognizer.State.ended
        }
        if(view.center.x > self.view.center.x + (self.view.frame.width/2) + 20){
            //previousPic()
        }
        
        if(sender.state == UIGestureRecognizer.State.ended){
            UIView.animate(withDuration: 0.7) {
                if(self.originalFrame != nil){
                    view.frame = self.originalFrame!
                }else{
                    view.center = self.view.center
                }
                view.isHidden = false
            }
        }
        
    }
    
   func nextPic(){
    print("next pic")
    if(self.peopleToRate == nil || self.peopleToRate.count == 0){
        return
    }
    
    
        if(count == self.peopleToRate.count - 1){
            count = 0
        }else{
            count = count + 1
        }
    
        let url = self.peopleToRate[count].getPictures()[0]
        let person = self.peopleToRate[count]
        loadImage(urlString: url)
        let averageRate = Double(person.getTotalRate()) / Double(person.getTimesRated())
        self.usernameLabel.text = "\(self.peopleToRate[count].getUsername())   Average Rate: \(String(format: "%.2f", averageRate))"
        self.imageView.center = self.view.center
    }
    func previousPic(){
        print("previous pic")
        if(count ==  0){
            count = self.peopleToRate.count - 1
        }else{
            count = count - 1
        }
        let url = self.peopleToRate[count].getPictures()[0]
        loadImage(urlString: url)

        self.usernameLabel.text = self.peopleToRate[count].getUsername()
        self.imageView.center = self.view.center
    }
    
    
}


