//
//  UserManager.swift
//  GroupProject
//
//  Created by Olivia Reese on 4/9/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class UserManager: NSObject,  ObservableObject {
    let db = Firestore.firestore()

    @Published var matchingUsernames: [String] = []
    @Published var username: String? = nil

    func searchUsers(searchText: String) {
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThan: searchText + "\u{f8ff}")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error searching for users: \(error)")
                    self.matchingUsernames = []
                } else {
                    if searchText != "" {
                        var userIds: [String] = []
                        for document in querySnapshot!.documents {
                            let userId = document.get("uid") as! String
                            userIds.append(userId)
                        }
                        self.getUsernames(for: userIds)
                    }
                }
            }
    }

    private func getUsernames(for userIds: [String]) {
        guard !userIds.isEmpty else {
            // If the array of user IDs is empty, set matchingUsernames to an empty array
            self.matchingUsernames = []
            return
        }
        
        db.collection("users")
            .whereField(FieldPath.documentID(), in: userIds)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching user documents: \(error)")
                    self.matchingUsernames = []
                } else {
                    var usernames: [String] = []
                    for document in querySnapshot!.documents {
                        let username = document.get("username") as! String
                        usernames.append(username)
                    }
                    self.matchingUsernames = usernames
                }
            }
    }
    
    func getUsernameByEmail(_ email: String) -> String? {
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments() { querySnapshot, error in
            if let error = error {
                print("Error retrieving post: \(error)")
            } else if let document = querySnapshot?.documents.first {
                print("Got post document: \(document.data())")
                let data = document.data()
                
                
                if var username = data["username"] as? String? ?? "" {
                    self.username = username
                    print(self.username ?? "error")
                }
            }
        }
        return self.username
    }
    
    func didUploadImageChange() {
        print("hello")
    }
}


//struct ImagePicker: UIViewControllerRepresentable {
//    
//}
