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

class NextSignUpViewController: UIViewController {
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var bio: UITextView!
    
    @IBOutlet weak var instagramTextfield: UITextField!
    
    
    var gender = "m"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
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
    

   

}
