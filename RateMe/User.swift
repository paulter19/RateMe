//
//  User.swift
//  RateMe
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import Foundation
class User{
    private var username:String = ""
    private var email:String = ""
    private var userID:String = ""
    private var pictures = [""]
    private var peopleIRated = [""]
    private var rateTotal = 10
    private var timesRated = 1


    
    init(username:String,email:String,uid:String,pics:[String]){
        self.username = username
        self.email = email
        self.userID = uid
        self.pictures = pics
        
    }
    init(){
        
    }
    
    func setUsername(un:String){
        self.username = un
    }
    func setUID(uid:String){
        self.userID = uid
    }
    func setEmail(email:String){
        self.email = email
    }
    func setPictures(pics:[String]){
        self.pictures = pics
    }
    func setRates(rates: [String]){
        self.peopleIRated = rates
    }
    func getRates() -> [String] {
        return self.peopleIRated 
    }
    func getPictures() -> [String] {
        return self.pictures
    }
    func getEmail() -> String {
        return self.email
    }
    func getUsername() -> String {
        return self.username
    }
    func getUid() -> String {
        return self.userID
    }
    func getTimesRated() -> Int {
        return self.timesRated
    }
    func getTotalRate() -> Int {
        return self.rateTotal
    }
    func setTimesRated(amount:Int){
        self.timesRated = amount
    }
    func setTotalRate(amount:Int){
        self.rateTotal = amount
    }
    
    
    
    
    
}
