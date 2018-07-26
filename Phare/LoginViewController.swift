//
//  LoginViewController.swift
//  Phare
//
//  Created by Cynthia Zhou on 7/18/18.
//  Copyright © 2018 Cynthia Zhou. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import Alamofire
import SwiftKeychainWrapper

// auth_token stored in KeyChain --- not string?

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var FBButton: UIButton!
    var token: String!
    var myToken: String!
    // var auth_token: String!
    var isLogged: Bool! = false
    let newScreen = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    @IBAction func FBTap(_ sender: Any) {
        
        // LOGOUT
        if isLogged {
            isLogged = false
            let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "myKey")
            if removeSuccessful {
                print ("KeyChain successfully removed")
            }
            else {
                print ("Error: KeyChain was not removed")
                // QUIT?
            }
            
            let loginMan = FBSDKLoginManager()
            loginMan.logOut()
            //FBSDKAccessToken.current = nil
            //FBSDKProfile.current = nil
            LoginManager().logOut()
            newScreen.text = "logged out"      // only appears if user is already logged in and then decides to log out
            print("logged out")
            
            // should be nil
            let retrievedString: String? = KeychainWrapper.standard.string(forKey: "myKey")
            print("retrievedString is \(String(describing: retrievedString))")
            
            self.FBButton.setTitle("Log In", for: .normal)
            print("USER LOGGED OUT")
            
        }
        
        // LOGIN
            else {
            // FB authentification
            isLogged = true
            let loginManager = LoginManager()
            loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
                switch loginResult {
                case .failed(let error):
                    print("Error: \(error)")
                    // QUIT?
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("accessToken: " +  accessToken.authenticationToken)
                    self.token = accessToken.authenticationToken
                    // print(self.token)
                    
                    let parameters: Parameters = ["access_token": self.token]
                    // Alamofire.request("35.183.136.242/get", method: .get, parameters: parameters, encoding: JSONEncoding.default)

                    Alamofire.request("http://35.183.136.242:3300/login/facebook_login/", method: .get, parameters: parameters).responseString { response in
                        print("Success: \(response.result.isSuccess)")
                        print("Response String: \(String(describing: response.result.value))")
                        //print("Request: \(String(describing: response.request))")   // original url request
                        print("Response: \(String(describing: response.response))") // http url response
                        print("Result: \(response.result)")                         // response serialization result

                        switch response.result {
                        case .success(let value):
                            print("It worked! \(value)")
                        case .failure(let error):
                            print(error)
                        }
                        
                        let auth_token = response.result.value
                        // self.auth_token = response.result.value
                        // debugPrint(response)
                        let saveSuccessful: Bool = KeychainWrapper.standard.set(auth_token!, forKey: "myKey")
                        
                        if saveSuccessful {
                            print("KeyChain Success: \(saveSuccessful)")
                            let retrievedString: String? = KeychainWrapper.standard.string(forKey: "myKey")
                            print ("retrievedString is \(String(describing: retrievedString))")
                        }
                        else {
                            print("Error: KeyChain was not successfully saved")
                        }
                    }

                    self.FBButton.setTitle("Log Out", for: .normal)
                    print("USER LOGGED IN")
                    
                    break
                } // end of case .success
            } // end of switch
            } // end of else
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let FB = FBSDKLoginButton()
        FB.readPermissions = ["public_profile", "email"]
        FB.delegate = self
        FB.center = self.view.center
        //self.view.addSubview(FB)
        
        if FBSDKAccessToken.current() != nil {
            FBButton.setTitle("Logged In", for: .normal)
            print("FB TOKENNNN")
        }
            
        else {
            FBButton.setTitle("Not Logged In", for: .normal)
        }
        
        //print("AUTH_TOKEN: \(auth_token)")
        
        // set FBButton font, color, text, border
        //FBButton.layer.borderWidth = 1
        //FBButton.backgroundColor = .clear
        //FBButton.layer.borderColor = UIColor.blue.cgColor
        //FBButton.layer.cornerRadius = 26
        FBButton.setTitle("Facebook", for: .normal)
        FBButton.setTitleColor(UIColor.blue, for: .normal)
        FBButton.titleLabel?.font =  UIFont(name: "Avenir", size: 15)
        
        let retrievedString: String? = KeychainWrapper.standard.string(forKey: "myKey")
        if retrievedString == nil {
            print ("Error: retrievedString is \(String(describing: retrievedString))")
        }
        else {
            
            //label.center = CGPointMake(160, 284)
            //label.textAlignment = NSTextAlignment.Center
            print ("already stored auth_token")
            print ("retrievedString is \(String(describing: retrievedString))")

            // move to next screen instead
            newScreen.text = "next screen"          // appears if user is already logged in
            newScreen.center = self.view.center
            self.view.addSubview(newScreen)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            FBButton.setTitle("Error", for: .normal)
            print("ERROR!!!!!! \(error)")
        }
        else if result.isCancelled {
            FBButton.setTitle("User Cancelled Login", for: .normal)
            print("CANCELLED")
        }
        else {
            FBButton.setTitle("User Logged In", for: .normal)
            print("LOGGED IN")
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        FBButton.setTitle("User Logged Out", for: .normal)
        print("LOGGED OUT")
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


/*
 Resources (links to look at):
 https://stackoverflow.com/questions/42802404/swift-get-facebook-accesstoken
 https://medium.com/@taylorhughes/the-right-way-to-implement-facebook-login-in-a-mobile-app-57e2eca3648b
 https://github.com/Alamofire/Alamofire
 https://stackoverflow.com/questions/26071061/sending-accesstoken-to-server-using-swift-ios
 https://medium.com/ios-os-x-development/securing-user-data-with-keychain-for-ios-e720e0f9a8e2
 
 
 */



