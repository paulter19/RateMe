//
//  SignInViewController.swift
//  RateMe
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        let userN = self.emailTextfield.text
        let pass = self.passwordTextfield.text
        
        Auth.auth().signIn(withEmail: userN!, password: pass!) { (user, error) in
            if(error == nil){
                print("sucess signing in")
                
                let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
                self.present(home, animated: false, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "Invalid Username or Password", message: "Check Capitalization", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                )
                self.present(alert, animated: true, completion: nil)
                
            }
            
            
            
        }
        
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismiss keyboard")
        view.endEditing(true)
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
