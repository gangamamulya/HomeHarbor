//
//  SplitWise.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/23/24.
//

/**
    *Challenge: Design a (utlities splitting + rent) app which shows individual utlities and rent that each renter needed to pay.*
*Calculations*:
 
 *Rent:*
 *Emily: 1395
 *John: 1000
 *Colton: 1000
 *Caleb:  950
 *Ammu
 *Siri
        *utilities:*
 * (Gas,Electricity,Internet,Garbage,Water and sewer bill)
 * Gas,Electricity,Garbage,Water,sewer bill will be equally divided among roomates.
 * utlity bill = Utility/6
                Internet:
 *Will be 60/6 for everyone
 *Caleb & John : 60/6 + (Internet bill - 60)/2
 
 *Expected Output:*
 Heading:
 MONTHLY EXPENSES FOR RENTER
 Enter following details:
 Gas bill:
 Electricity:
 Internet:
 Garbage:
 Water:

 
 OUTPUT:
 Emily's bill is:    Rent: _   Utilities: _     Total:
 John's bill is:     Rent: _   Utilities: _     Total:
 Caleb's bill is:    Rent: _   Utilities: _     Total:
 Colton's bill is:    Rent: _   Utilities: _     Total:
 */
import Foundation
class SplitWise {
    static let shared = SplitWise()
    struct MyDetails: Equatable {
        var name: [String]
        var rent: [String:Int]
        var utilities: Utilities
    }
    
    struct Utilities: Equatable {
        var gas: Double
        var electricity: Double
        var internet: Double
        var garbage: Double
        var waterAndSewer: Double
    }
    
    enum UserType: String {
        case owner
        case tenant
    }
    
    static func showMySplit(details: MyDetails, utilities:Utilities) -> [String: Double] {
        let roomatesCnt = details.name.count
        ///TOTAL UTILITIES WITHOUT INTERNET
        let totalBillWithoutInternet = (utilities.gas + utilities.electricity + utilities.garbage + utilities.waterAndSewer)
        ///TOTAL UTILITIES WITHOUT INTERNET SHARE
        let utitlitiesShareWithoutInternet = ((totalBillWithoutInternet) / Double(roomatesCnt))
        ///INTERNET SHARE
        let basicInternetShare = (60.0 / Double(roomatesCnt))
        ///CALEB AND JOHN INTERNET SHARE
        let calebAndJohnInternetShare = ((utilities.internet - 60)/2 ) + (basicInternetShare)
        
        var bills = [String: Double]()
        for name in details.name {
            var individualBill = utitlitiesShareWithoutInternet
            if name == "Caleb" || name == "John" {
                individualBill += calebAndJohnInternetShare
            }
            else {  individualBill += basicInternetShare }
            bills[name] = individualBill
        }
        return bills
    }
}
