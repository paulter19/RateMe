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

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    var profileUpload = UIImage(named: "default")
    var changedProfilePic = false
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
            if(error == nil){
                
                let uid = user?.user.uid
                let randomString = UUID().uuidString

                let storRef = Storage.storage().reference().child("ProfilePics").child(uid!).child(randomString)
                
                if let uploadData = self.profileUpload?.jpegData(compressionQuality: 0.4){
                    storRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        self.signUpButton.isEnabled = false
                        storRef.downloadURL(completion: { (url, error) in
                            if(error != nil){
                                return
                            }
                            
                            let username = self.usernameTextfield.text
                            let email = self.emailTextfield.text?.uppercased()
                            let dref = Database.database().reference().child("Users").child((user?.user.uid)!).setValue(["username":username,"email":email,"userID":uid,"Pictures":[url?.absoluteString],"rateTotal":10,"timesRated":1])
                            
                            
                            let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
                            self.present(home, animated: true, completion: nil)
                            
                            
                            
                            
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
    





fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
}
