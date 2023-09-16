//
//  PostsManager.swift
//  GroupProject
//
//  Created by Olivia Reese on 4/8/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PostsManager: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userPost: Post? = nil
    private var likes: String? = nil
    @Published var hasPosted: Bool = false
    private var userEmail: String? = nil
    let friendsManager = FriendsManager()
    
    init() {
        let _ = fetchPosts()
    }
    
    func fetchPosts() -> [Post] {
        posts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collectionGroup("Posts")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let userID = data["userID"] as? String ?? ""
                    let username = data["username"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let link = data["link"] as? String ?? ""
                    let genre = data["genre"] as? String ?? ""
                    let linktype = data["linktype"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let likes = data["likes"] as? String ?? ""
                    
                    let post = Post(username: username, userID: userID, genre: genre, id: id, link: link, linktype: linktype, email: email, text: text, likes: likes)
                    self.posts.append(post)
                }
            }
        }
        
        return self.posts
    }
    
    func addPost(link: String, genre: String, linktype: String, text: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Posts").document(link)
        let id = UUID()
        let email = Auth.auth().currentUser?.email
        let userID = Auth.auth().currentUser?.uid
        let likes = 0
        
        friendsManager.getUsername(userID: userID ?? "") { username in
            ref.setData(["userID": userID as Any, "username": username, "link": link, "id": id.uuidString, "genre": genre, "linktype": linktype, "email": email as Any, "text": text, "likes": likes]) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        hasPosted = true

    }
    
    // gets the post of the user with uid userID
    func getPost(userID: String) -> Post? {
        setUserEmail(userID: userID)
        let db = Firestore.firestore()
        if hasPosted {
            if let userEmail = getUserEmail() {
                db.collection("Posts").whereField("email", isEqualTo: userEmail).getDocuments() { querySnapshot, error in
                    if let error = error {
                        print("Error retrieving post: \(error)")
                    } else if let document = querySnapshot?.documents.first {
                        print("Got post document: \(document.data())")
                        let data = document.data()
                        
                        let userID = data["userID"] as? String ?? ""
                        let username = data["username"] as? String ?? ""
                        let id = data["id"] as? String ?? ""
                        let link = data["link"] as? String ?? ""
                        let genre = data["genre"] as? String ?? ""
                        let linktype = data["linktype"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let text = data["text"] as? String ?? ""
                        let likes = data["likes"] as? String ?? ""
                         
                        let post = Post(username: username, userID: userID, genre: genre, id: id, link: link, linktype: linktype, email: email, text: text, likes: likes)
                        self.userPost = post
                    }
                }
            } else {
                return nil
            }
            
            return self.userPost
        } else {
            return nil
        }
    }
    
    func likePost( _ email: String) -> Void {
        print("email" + email)
        
        let db = Firestore.firestore()
        db.collection("Posts").whereField("email", isEqualTo: email).getDocuments() { querySnapshot, error in
            if let error = error {
                print("Error retrieving post: \(error)")
            } else if let document = querySnapshot?.documents.first {
                print("Got post document: \(document.data())")
                let data = document.data()
                
//                let liked_by = data["liked_by"]
                let likes = data["likes"] as! Int + 1
                
//                let lb = data["liked_by"] as? [String]?
                
                
                let document = querySnapshot!.documents.first
                document?.reference.updateData([
                    "likes": likes
                ])
                print("liked post " + String(likes))
            }
        }
//        return self.likes
    }
    
    func getLikes(_ email: String) -> String? {
        let db = Firestore.firestore()
        db.collection("Posts").whereField("email", isEqualTo: email).getDocuments() { querySnapshot, error in
            if let error = error {
                print("Error retrieving post: \(error)")
            } else if let document = querySnapshot?.documents.first {
                print("Got post document: \(document.data())")
                let data = document.data()
                
                
                if let l = data["likes"] as? String? ?? String(data["likes"] as? Int ?? 0) {
                    self.likes = l
                    print(self.likes ?? "error")
                }
            }
        }
        return self.likes
    }
    
    func setUserEmail(userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument() { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
                self.userEmail = nil
            } else {
                if let document = document, document.exists {
                    let data = document.data()!
                    let email = data["email"] as! String
                    self.userEmail = email
                }
            }
        }
    }
    
    func getUserEmail() -> String? {
        return self.userEmail
    }
}


