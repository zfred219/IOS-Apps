//
//  FeedData.swift
//  Snapagram
//
//  Created by Arman Vaziri on 3/8/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// Create global instance of the feed
var feed = FeedData()
let storage = Storage.storage()
let db = Firestore.firestore()


class Thread {
    var name: String
    var emoji: String
    var entries: [ThreadEntry]
    
    
    
    init(name: String, emoji: String) {
        self.name = name
        self.emoji = emoji
        self.entries = []
    }
    
    func addEntryDefault(threadEntry: ThreadEntry){
        entries.append(threadEntry)
    }
    
    func addEntry(threadEntry: ThreadEntry) {
        entries.append(threadEntry)
        threadWrite(threadEntry: threadEntry, threadName: self.name)
    }
    
    func removeFirstEntry() -> ThreadEntry? {
        if entries.count > 0 {
            delDbThread(thread: self)
            return entries.removeFirst()
        }
        return nil
    }
    
    func unreadCount() -> Int {
        return entries.count
    }
    
}

struct ThreadEntry {
    var username: String
    var image: UIImage
}

struct Post {
    var location: String
    var image: UIImage?
    var user: String
    var caption: String
    var date: Date
}

class FeedData {
    //TODO: change for multi user
    var username = "Default"
    
    
    var threads: [Thread] = [
        Thread(name: "memes", emoji: "😂"),
        Thread(name: "dogs", emoji: "🐶"),
        Thread(name: "fashion", emoji: "🕶"),
        Thread(name: "fam", emoji: "👨‍👩‍👧‍👦"),
        Thread(name: "tech", emoji: "💻"),
        Thread(name: "eats", emoji: "🍱"),
    ]
    
    // Adds dummy posts to the Feed
    var posts: [Post] = [
        Post(location: "New York City", image: UIImage(named: "skyline"), user: "nyerasi", caption: "Concrete jungle, wet dreams tomato 🍅 —Alicia Keys", date: Date(timeIntervalSinceNow: TimeInterval(-Int.random(in: 10000 ... 15000)))),
        Post(location: "Memorial Stadium", image: UIImage(named: "garbers"), user: "rjpimentel", caption: "Last Cal Football game of senior year!", date: Date(timeIntervalSinceNow: TimeInterval(-Int.random(in: 5000 ... 10000)))),
        Post(location: "Soda Hall", image: UIImage(named: "soda"), user: "chromadrive", caption: "Find your happy place 💻", date: Date(timeIntervalSinceNow: TimeInterval(-Int.random(in: 0 ... 5000))))
    ]
    
    // Adds dummy data to each thread
    /*
     init() {
     for thread in threads {
     let entry = ThreadEntry(username: self.username, image: UIImage(named: "garbers")!)
     thread.addEntryDefault(threadEntry: entry)
     }
     }
     */
    
    func addPost(post: Post) {
        posts.append(post)
        postWrite(post: post)
    }
    
    
    // Optional: Implement adding new threads!
    func addThread(thread: Thread) {
        threads.append(thread)
    }
    
}


// write firebase functions here (pushing, pulling, etc.)


func threadWrite(threadEntry: ThreadEntry, threadName: String) {
    let imageID = UUID.init().uuidString
    
    // 2 store thread
    let storageRef = storage.reference(withPath: "images/\(imageID).jpg")
    guard let imageData = threadEntry.image.jpegData(compressionQuality: 0.75) else { return }
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "image/jpeg"
    storageRef.putData(imageData)
    
    // 1 write thread
    var ref: DocumentReference? = nil
    ref = db.collection("Threads").addDocument(data: [
        "threadName": threadName,
        "user": threadEntry.username,
        "imageID": imageID,
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }
}


func postWrite(post: Post){
    let imageID = UUID.init().uuidString
    //2 store
    let storageRef = storage.reference(withPath: "images/\(imageID).jpg")
    guard let imageData = post.image?.jpegData(compressionQuality: 0.75) else { return }
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "image/jpeg"
    storageRef.putData(imageData)
    
    // 1write
    var ref: DocumentReference? = nil
    ref = db.collection("Posts").addDocument(data: [
        "location": post.location,
        "imageID": imageID,
        "user": post.user,
        "caption": post.caption,
        "date": post.date
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document added with ID: \(ref!.documentID)")
        }
    }
}

func fetchPosts() {
    db.collection("Posts").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            var location: String
            var imageID: String
            var user: String
            var caption: String
            var date: Timestamp
            
            for document in querySnapshot!.documents {
                print(document.data())
                location = document.data()["location"] as! String
                imageID = document.data()["imageID"] as! String
                user = document.data()["user"] as! String
                caption = document.data()["caption"] as! String
                date = document.data()["date"] as! Timestamp
                
                //TODO: must be immutable to run the download, don know why but doable
                let location1 = location
                let storageRef = storage.reference(withPath: "images/\(imageID).jpg")
                let user1 = user
                let caption1 = caption
                let date = Date(timeIntervalSince1970: TimeInterval(date.seconds))
                
                storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        print("Error getting data")
                    }
                    if let data = data {
                        let image = UIImage(data: data)
                        print("This is \(image!)")
                        feed.posts.append(Post(location: location1, image: image!, user: user1, caption: caption1, date: date))
                    }
                }
            }
        }
    }
}

func fetchThreads() {
    db.collection("Threads").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            var imageID: String
            var user: String
            var threadName: String
            
            for document in querySnapshot!.documents {
                print(document.data())
                imageID = document.data()["imageID"] as! String
                user = document.data()["user"] as! String
                threadName = document.data()["threadName"] as! String
                
                
                //TODO: must be immutable to run the download, don know why but doable
                let storageRef = storage.reference(withPath: "images/\(imageID).jpg")
                let user1 = user
                let threadName1 = threadName
                
                storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        print("Error getting data")
                    }
                    if let data = data {
                        let image = UIImage(data: data)
                        print("This is \(image!)")
                        for thread in feed.threads {
                            if (thread.name == threadName1){
                                thread.addEntryDefault(threadEntry: ThreadEntry(username: user1, image: image!))
                            }
                        }
                    }
                }
            }
        }
    }
}

//TODO: delete the corresponding image in storage to save space
func delDbThread(thread: Thread) {
    db.collection("Threads").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                if (document.data()["threadName"] as! String == thread.name) {
                    document.reference.delete()
                }
            }
        }
    }
}
