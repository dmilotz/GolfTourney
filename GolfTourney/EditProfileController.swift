//
//  EditProfileController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/20/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UIKit

class EditProfileController: UIViewController{
    
    var ref: FIRDatabaseReference!
    let uid = FIRAuth.auth()?.currentUser?.uid
    var user: Player?
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBAction func changeProfileImage(_ sender: Any) {
        handleSelectProfileImage()
    }
    
    
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var handicapField: UITextField!
    
    @IBOutlet var zipField: UITextField!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: UIButton) {
        updateUserInfoInDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        nameField.delegate = self
        emailField.delegate = self
        handicapField.delegate = self
        zipField.delegate = self
        subscribeToKeyboardNotifications()
       getUserInfo()
    }
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(false)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    func getUserInfo(){
        NetworkClient.getUserInfo(userId: uid!) { (dict, error) in
            if error == nil{
                self.user = Player(dict: dict!)
                self.setProfileFields()
            }
            else{
                self.displayAlert(error as! String, title: "Error")
            }
            
        }
    }
    
    func setProfileFields(){
        emailField.text = user!.email
        nameField.text = user!.name
        handicapField.text = user!.handicap
        if let url = user!.profileImageUrl{
            NetworkClient.getDataFromUrl(url: NSURL(string: url) as! URL, completion: { (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async{
                        self.displayAlert("Error downloading profile image", title: "Error")
                        return
                    }
                }
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data:data!)
                }
            })
        }else{
            self.profileImage.image = UIImage(named:"golfDefault.png")
        }
        
        
    }
    
    func updateUserInfoInDatabase(){
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profileImage").child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(profileImage.image!){
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    
                    let userRef = self.ref.child("users").child(self.uid!)
                    let values = ["profileImage": imageUrl, "userName": self.nameField.text!, "email": self.emailField.text!, "handicap": self.handicapField.text!, "zipCode": self.zipField.text!]
                    userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil{
                            print(error)
                            return
                        }
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
            })
        }
        
        
    }
    
    
}
extension EditProfileController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        //
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {   let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        //Define text limits for handicap and zip code fields
        
        if textField.tag == 30 && !string.isEmpty  {
            let maxLength = 2
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if allowedCharacters.isSuperset(of: characterSet){
                return (newString.length <= maxLength) && (Int(newString as String)! <= 36)
            }
            else{
                return false
            }
        }else if textField.tag == 40 && !string.isEmpty{
            let maxLength = 5
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && allowedCharacters.isSuperset(of: characterSet)
        }
        else{
            return true
        }
        
    }
    
    //
    //    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
    //                   replacementString string: String) -> Bool
    //    {
    //        if textField.tag == 30 {
    //            let maxLength = 2
    //            let currentString: NSString = textField.text! as NSString
    //            let newString: NSString =
    //                currentString.replacingCharacters(in: range, with: string) as NSString
    //            return (newString.length <= maxLength) && (Int(newString as! String)! <= 36)
    //        }else if textField.tag == 40{
    //            let maxLength = 5
    //            let currentString: NSString = textField.text! as NSString
    //            let newString: NSString =
    //                currentString.replacingCharacters(in: range, with: string) as NSString
    //            return newString.length <= maxLength
    //        }
    //        else{
    //            return true
    //        }
    //
    //    }
    
}
extension EditProfileController{
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWillShow(notification: Notification) {
        if handicapField.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification: notification) - 20
        }else if zipField.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification: notification) - 20
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}




extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleSelectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //var selectedImage: UIImage?
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImage.image = image.resized(withPercentage: 0.1)
        }
        dismiss(animated: true, completion: nil)
        //updateUserPhotoInDatabase()
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

