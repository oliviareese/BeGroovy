//
//  FriendsManager.swift
//  GroupProject
//
//  Created by Olivia Reese on 4/9/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FriendsManager: ObservableObject {
    let db = Firestore.firestore()
    
    // Function to send a friend request
    func sendFriendRequest(senderID: String, recipientID: String) {
        db.collection("friendRequests").addDocument(data: [
            "senderID": senderID,
            "recipientID": recipientID,
            "status": "pending"
        ])
    }
    
    func getUID(forUsername username: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil)
            } else {
                for document in querySnapshot!.documents {
                    let recipientUid = document.documentID
                    completion(recipientUid)
                    return
                }
                completion(nil)
            }
        }
    }
    
    
    // Function to respond to a friend request
    func respondToFriendRequest(senderID: String, recipientID: String, accepted: Bool, completion: @escaping (Bool) -> Void) {
        let query = db.collection("friendRequests")
                .whereField("senderID", isEqualTo: senderID)
                .whereField("recipientID", isEqualTo: recipientID)
        
        query.getDocuments() { querySnapshot, error in
                if let error = error {
                    print("Error getting friend request document: \(error)")
                    completion(false)
                } else if let document = querySnapshot?.documents.first {
                    print("Got friend request document: \(document.data())")
                    let documentID = document.documentID
                    let requestRef = self.db.collection("friendRequests").document(documentID)

                    // Update the request document
                    var data = document.data()
                    data["status"] = accepted ? "accepted" : "rejected"
                    requestRef.updateData(data) { error in
                        if let error = error {
                            print("Error updating friend request document: \(error)")
                            completion(false)
                        } else {
                            // If request was accepted, create a friendship document
                            if accepted {
                                let user1ID = document.get("senderID") as! String
                                let user2ID = document.get("recipientID") as! String
                                let friendshipData = [
                                    "user1ID": user1ID,
                                    "user2ID": user2ID
                                ]
                                self.db.collection("friendships").addDocument(data: friendshipData) { error in
                                    if let error = error {
                                        print("Error creating friendship document: \(error)")
                                        completion(false)
                                    } else {
                                        completion(true)
                                    }
                                }
                            } else {
                                completion(true)
                            }
                        }
                    }
                } else {
                    print("No friend request document found for senderID \(senderID) and recipientID \(recipientID)")
                    completion(false)
                }
            }
    }
    
    
    // Function to create a new friendship document
    func createFriendship(user1ID: String, user2ID: String) {
        db.collection("friendships").addDocument(data: [
            "user1ID": user1ID,
            "user2ID": user2ID
        ])
    }
    
    // Function to retrieve a user's friends
    func getUserFriends(userID: String, completion: @escaping ([String]) -> Void) {
        var friendIDs = [String]()
        
        db.collection("friendships").whereField("user1ID", isEqualTo: userID).getDocuments() { querySnapshot, error in
                if let error = error {
                    print("Error retrieving user's friends: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        friendIDs.append(document.get("user2ID") as! String)
                    }
                }
            
                self.db.collection("friendships").whereField("user2ID", isEqualTo: userID).getDocuments() { querySnapshot, error in
                    if let error = error {
                        print("Error retrieving user's friends: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            friendIDs.append(document.get("user1ID") as! String)
                        }
                    }
                    completion(friendIDs)
                }
            }
        
//        db.collection("friendships").whereField(FieldPath(["user1ID", "user2ID"]), in: [userID])
//            .getDocuments() { querySnapshot, error in
//                if let error = error {
//                    print("Error retrieving user's friends: \(error)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        let user1ID = document.get("user1ID") as! String
//                        let user2ID = document.get("user2ID") as! String
//                        let friendID = (user1ID == userID) ? user2ID : user1ID
//                        friendIDs.append(friendID)
//                    }
//                }
//                completion(friendIDs)
//            }
    }
    
    // Function to retrieve a user's friend requests
    func getUserFriendRequests(userID: String, completion: @escaping ([(senderID: String, status: String)]) -> Void) {
        var friendRequests = [(senderID: String, status: String)]()
        db.collection("friendRequests").whereField("recipientID", isEqualTo: userID).whereField("status", isEqualTo: "pending")
            .getDocuments() { querySnapshot, error in
                if let error = error {
                    print("Error retrieving user's friend requests: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let senderID = document.get("senderID") as! String
                        let status = document.get("status") as! String
                        friendRequests.append((senderID: senderID, status: status))
                    }
                }
                completion(friendRequests)
            }
    }
    
    func getUsername(userID: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(userID).getDocument() { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()!
                    let username = data["username"] as! String
                    completion(username)
                }
            }
        }
    }
    
    func getEmail(userID: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(userID).getDocument() { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()!
                    let email = data["email"] as! String
                    completion(email)
                }
            }
        }
    }
    
    func getUsernameFromEmail(email: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(email).getDocument() { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()!
                    let username = data["username"] as! String
                    completion(username)
                }
            }
        }
    }
}
