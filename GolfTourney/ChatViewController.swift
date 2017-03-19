//
//  ChatViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 3/16/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import JSQMessagesViewController
import UIKit

class ChatViewController: JSQMessagesViewController{
  
  /// Properties
  let curUser = FIRAuth.auth()?.currentUser?.uid
  var ref: FIRDatabaseReference!
  var chatRef: FIRDatabaseReference! {
    return ref.child("chats").child("TESTGAME")
  }
  var game: Game?
  var player: Player?
  var newMessageRefHandle: FIRDatabaseHandle?
  
  var messages = [JSQMessage]()
  lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
  lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
  
  @IBOutlet var navBar: UINavigationBar!
  
  @IBAction func back(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad(){
    super.viewDidLoad()
    //let navBarbutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: Selector("back"))
    ref = FIRDatabase.database().reference()
    self.senderDisplayName = "No Name"
    getUserInfo()
    observeMessages()
    self.senderId = FIRAuth.auth()?.currentUser?.uid
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // messages from someone else
    addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
    // messages sent from local sender
    addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
    addMessage(withId: senderId, name: "Me", text: "I like to run!")
    // animates the receiving of a new message on the view
    finishReceivingMessage()
  }
  
}

extension ChatViewController{
  
  func addMessage(withId id: String, name: String, text: String) {
    if let message = JSQMessage(senderId: id, displayName: name, text: text) {
      messages.append(message)
    }
  }
  
  func getUserInfo(){
    NetworkClient.getUserInfo(userId: curUser!) { (dict, error) in
      if error != nil{
        print("Error retrieving user")
        return
      }else{
        self.player = Player(dict: dict!)
        self.player?.uid = self.curUser!
        if let name = self.player?.name{
          self.senderDisplayName = name
        }else{
          self.senderDisplayName = "No name"
        }
      }
    }
  }
  
  
}

// MARK: - JSQMessage functions
extension ChatViewController{
  func observeMessages() {
    let messageQuery = chatRef.queryLimited(toLast:25)
    
    // 2. We can use the observe method to listen for new
    // messages being written to the Firebase DB
    newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
      // 3
      let messageData = snapshot.value as! Dictionary<String, String>
      
      if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
        // 4
        self.addMessage(withId: id, name: name, text: text)
        // 5
        self.finishReceivingMessage()
      } else {
        print("Error! Could not decode message data")
      }
    })
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item] // 1
    if message.senderId == senderId { // 2
      return outgoingBubbleImageView
    } else { // 3
      return incomingBubbleImageView
    }
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    // Sent by me, skip
    let message = messages[indexPath.item];
    if message.senderId == senderId {
      return nil;
    }else{
      let image = UIImage(named:"golfDefault.png")!.circle
      let avatar = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
      return avatar as JSQMessageAvatarImageDataSource!
    }
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    let itemRef = chatRef.childByAutoId() // 1
    let messageItem = [ // 2
      "senderId": senderId!,
      "senderName": senderDisplayName!,
      "text": text!,
      ]
    
    itemRef.setValue(messageItem) // 3
    
    JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
    
    finishSendingMessage()
  }
  //  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
  //    <#code#>
  //  }
  
  //MARK: To View  usernames above bubbles
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let message = messages[indexPath.item];
    
    // Sent by me, skip
    if message.senderId == senderId {
      return nil;
    }
    
    // Same as previous sender, skip
    if indexPath.item > 0 {
      let previousMessage = messages[indexPath.item - 1];
      if previousMessage.senderId == message.senderId {
        return nil;
      }
    }
    
    return NSAttributedString(string:message.senderDisplayName)
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    let message = messages[indexPath.item]
    
    // Sent by me, skip
    if message.senderId == senderId {
      return CGFloat(0.0);
    }
    
    // Same as previous sender, skip
    if indexPath.item > 0 {
      let previousMessage = messages[indexPath.item - 1];
      if previousMessage.senderId == message.senderId {
        return CGFloat(0.0);
      }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault
    
  }
  
  
  func setupOutgoingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
  }
  
  func setupIncomingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
  }
  
  
  
}
