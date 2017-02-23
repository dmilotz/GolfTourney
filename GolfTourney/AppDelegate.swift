//
//  AppDelegate.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/6/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RealmSwift
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let config = Realm.Configuration(
            schemaVersion: 2,  // Must be greater than previous version
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // minimally this can be empty
                }
                if (oldSchemaVersion < 2) {
                    // minimally this can be empty
                }
                print("Realm migration did run")  // Log to know migration was executed
        })
        
        // Make sure to set the default configuration
        Realm.Configuration.defaultConfiguration = config
        openRealm()
        
        
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:]) || FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    
    func openRealm() {
        
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
        let bundleRealmPath = Bundle.main.url(forResource: "default2", withExtension: "realm")
        //    let myFilePathString = "/Users/dirkmilotz/Downloads/realm/coursesCompact.realm"
        //    let url = NSURL(string: myFilePathString)
        //    _ = try! Realm().writeCopy(toFile: url as! URL)
        if !FileManager.default.fileExists(atPath: defaultRealmPath.absoluteString) {
            do {
                try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
            } catch let error {
                print("error copying seeds: \(error)")
            }
        }
    }
    
//    func checkOrientation(viewController:UIViewController?)-> Int{
//        
//        if(viewController == nil){
//            
//            return Int(UIInterfaceOrientationMask.all.rawValue)//All means all orientation
//            
//        }else if (viewController is EditProfileController || viewController is LoginViewController || viewController is UserProfileController){
//            
//            return Int(UIInterfaceOrientationMask.portrait.rawValue)
//            
//        }else{
//            
//            return checkOrientation(viewController: viewController!.presentedViewController)
//        }
//    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
}

//Google delegate implementation

extension AppDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            print("Signed in!")
            if let error = error {
                print(error)
                return
            }
            else{
                if user != nil {
                    print("signed in")
                }
            }
        })
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

