//
//  PostViewController.swift
//  Snapagram
//
//  Created by Kaixiang Zhang on 3/19/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import UIKit

class PostViewController: UIViewController,
UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var imageToPost: UIImage!
    var currThread: Thread!
    var currPost: Post!
    
    
    
    @IBOutlet weak var postThreadCollectionView: UICollectionView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaption: UITextField!
    @IBOutlet weak var postLocation: UITextField!
    @IBOutlet weak var createThread: UIButton!
    @IBOutlet weak var postFeed: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 200, green: 200, blue: 200, alpha: 1)
        self.postImageView.image = imageToPost
        //TODO: internal text can be eliminated by click
        collectionView.layer.borderColor = UIColor.gray.cgColor
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderWidth = 2
        
        postThreadCollectionView.allowsMultipleSelection = true
        postLocation.layer.cornerRadius = 5
        postLocation.layer.borderColor = UIColor.black.cgColor
        postCaption.layer.cornerRadius = 5
        postCaption.layer.borderColor = UIColor.black.cgColor
        createThread.layer.cornerRadius = 8
        postFeed.layer.cornerRadius = 8
        
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.layer.cornerRadius = 10
        postImageView.layer.borderWidth = 2
        postImageView.layer.borderColor = UIColor.black.cgColor
        
        postThreadCollectionView.dataSource = self
        postThreadCollectionView.delegate = self
    }
    
    @IBAction func postThread(_ sender: UIButton) {
        if let cT = currThread{
            for thread in feed.threads {
                if (thread.name == cT.name) {
                    thread.addEntry(threadEntry: ThreadEntry(username: "Fred" , image: imageToPost))
                    self.navigationController?.popToRootViewController(animated: true)
                    clearPost()
                }
            }
        } else {
            print("You have to choose a thread before post!")
            //TODO: May pop alert?
        }
        
    }
    
    @IBAction func postFeed(_ sender: UIButton) {
        //TODO: if have login, can have a user specification
        //FIXME: mintues ago ...
        let date = Date()
        currPost = Post(location: postLocation.text!, image: imageToPost, user: "Fred", caption: postCaption.text!, date: date)
        feed.addPost(post: currPost)
        self.navigationController?.popToRootViewController(animated: true)
        clearPost()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed.threads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let thread = feed.threads[index]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postThreadCell", for: indexPath) as? PostThreadCollectionViewCell {
            cell.emojiLabel.text = thread.emoji
            cell.nameLabel.text = thread.name
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    //TODO: multi thread select
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //FIXME: Need to be fixed double selection then double deselect
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 3.0
        cell?.layer.borderColor = UIColor.orange.cgColor
        
        let postChosenThread = feed.threads[indexPath.item]
        currThread = Thread(name: postChosenThread.name, emoji: postChosenThread.emoji)
        print(postChosenThread.name)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 3.0
        cell?.layer.borderColor = UIColor.white.cgColor
        //print("You deselect \(currThread.name)")
        currThread = nil
    }
    
    func clearPost() {
        postImageView.image = nil
        postCaption.text = nil
        postLocation.text = nil
    }
    
    /*
     let tapRecogniser = UITapGestureRecognizer()
     tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
     self.view.addGestureRecognizer(tapRecogniser)
     
     @objc func viewTapped(){
     self.view.endEditing(true)
     }
     */
}
