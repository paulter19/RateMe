//
//  SearchUser.swift
//  RateMe
//
//  Created by Paul Ter on 5/15/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import GoogleMobileAds

class SearchUser:UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    var users = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        print("appeared.....")
        self.mySearchBar.isFirstResponder
        let view = GADBannerView()
        view.frame = CGRect(x: 0, y: self.view.frame.maxY - 50, width: 320, height: 50)
        view.delegate = self
        view.rootViewController = self
        view.adUnitID = "ca-app-pub-1666211014421581/8054549109"
        view.load(GADRequest())
        self.view.addSubview(view)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = UIImage(named: "default.jpeg")
        
        let theUser = self.users[indexPath.row]
        
        cell.textLabel?.text = theUser.getUsername()
        cell.detailTextLabel?.text = theUser.getEmail()
        if(theUser.getPictures()[0] != nil){
            let url = theUser.getPictures()[0]
            loadImage(urlString: url,cell: cell)
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForUser(userInfo: searchText)

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
    }
    
    func searchForUser(userInfo: String){
        let ref = Database.database().reference().child("Users")
       print("searching. ..")
        
        ref.queryOrdered(byChild: "username").queryStarting(atValue: userInfo.lowercased()).queryEnding(atValue: "\(userInfo.lowercased())\\uf8ff")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                for d in dict.values{
                    let userDictionary = d as! [String:Any]
                    if((userDictionary["username"] as! String) == userInfo.lowercased() || (userDictionary["email"] as! String) == userInfo.lowercased() ){
                        
                        print("found")
                        let username = userDictionary["username"] as! String
                        let email = userDictionary["email"] as! String
                        let pictures = userDictionary["Pictures"] as! [String]
                        let uid = userDictionary["userID"] as! String
                        let timesRated = userDictionary["timesRated"] as! Int
                        let totalRate = userDictionary["rateTotal"] as! Int
                        let visibility = userDictionary["visibility"] as! String
                        let user = User(username: username, email: email, uid: uid, pics: pictures)
                        user.setVisibility(visibility: visibility)
                        user.setTotalRate(amount: totalRate)
                        user.setTimesRated(amount: timesRated)
                        
                        
                        if(userDictionary["peopleIRated"] != nil){
                            let irated = userDictionary["peopleIRated"] as! [String]
                            user.setRates(rates: irated)
                        }
                        self.users.append(user)
                        
                        DispatchQueue.main.async {
                            self.myTableView.reloadData()
                            
                            
                        }
                    }
                    
                    
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        self.present(profile, animated: true) {
            print("presenting")
            profile.cameFromSearch = true
            profile.searchInfo = self.users[indexPath.row]
            profile.setUpSearchedProfile()
            
        }
    }
    
    func loadImage(urlString:String, cell: UITableViewCell){
        
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
                    cell.imageView?.image = downloadedImage
                }
            }
        }).resume()
    
    
    
    
    
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
