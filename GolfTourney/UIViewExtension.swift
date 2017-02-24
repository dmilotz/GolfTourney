//
//  UIViewExtension.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/20/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//


import Foundation
import UIKit

extension UIViewController{
    
    func displayAlert(_ message: String, title: String){
        OperationQueue.main.addOperation {
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func displayOverwriteAlert() {
        let overwriteAlert = UIAlertController(title: "Cancel Game?", message: "Are you sure you want to cancel game?", preferredStyle: UIAlertControllerStyle.alert)
        
        overwriteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "EnterStudentInfoViewController")
            self.present(controller, animated: true, completion: nil)            }))
        
        overwriteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return            }))
        
        self.present(overwriteAlert, animated: true, completion: nil)
        
    }
    
}
