//
//  HomeView.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/27/23.
//

import SwiftUI
import Firebase
import LinkPresentation
import PhotosUI

//Link previews
struct LinkRow : UIViewRepresentable {
    var previewURL:URL
    @Binding var redraw: Bool
    
    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView(url: previewURL)
        
        DispatchQueue.global().async {
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: previewURL) { (metadata, error) in
                if let md = metadata {
                    DispatchQueue.main.async {
                        view.metadata = md
                        view.sizeToFit()
                        self.redraw.toggle()
                    }
                }
                
                else if error != nil {
                    let md = LPLinkMetadata()
                    md.title = "Custom title"
                    DispatchQueue.main.async {
                        view.metadata = md
                        view.sizeToFit()
                        self.redraw.toggle()
                    }
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ view: LPLinkView, context: Context) {
        // New instance for each update
    }
}

struct StringLink : Identifiable{
    var id = UUID()
    var string : String
}

struct SearchView: View {
    @StateObject var userManager = UserManager()
    @State private var searchText = ""
    @State private var showCancelButton = false
    @State private var showSearchBar = false
    @State private var isShowingResults = false
    let friendsManager = FriendsManager()

    var body: some View {
        Color.cyan.opacity(0.50)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Search For Friends")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.indigo)
                        .padding(.bottom, 30)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                                
                        TextField("Search users",
                            text: $searchText, onEditingChanged: { editing in
                                showCancelButton = true
                                }, onCommit: {
                                    userManager.searchUsers(searchText: searchText)
                                    isShowingResults = true
                                }
                        )
                        .padding()
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .frame(width: 240, height: 50)
                        .background(Color.black.opacity(0.10))
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                            
                    if isShowingResults {
                        VStack {
                            if userManager.matchingUsernames != [] {
                                ForEach(userManager.matchingUsernames, id: \.self) { username in
                                    HStack {
                                        Text(username)
                                        .font(.system(size: 20))
                                        .padding(.trailing, 190)
                                                    
                                    Button(action: {
                                        friendsManager.getUID(forUsername: username) { recipientUid in
                                            if let uid = recipientUid {
                                                let user = Auth.auth().currentUser
                                                let senderUid = user!.uid
                                                print("SENDER UID: ", senderUid)
                                                friendsManager.sendFriendRequest(senderID: senderUid, recipientID: uid)
                                            } else {
                                                print("User not found")
                                            }
                                        }
                                    }) {
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 25))
                                    }
                                }
                            }
                        } else {
                            Text("No matching results")
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
            }
            .frame(width: 300, height: 100, alignment: .leading)
        )
    }
}

struct FriendsView: View {
    var body: some View {
        Color.cyan.opacity(0.50)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Manage Friendships")
                        .font(.title)
                        .foregroundColor(.indigo)
                        .padding()
                    Spacer()
                    
                    TabView {
                        Friends()
                            .tabItem {
                                Text("Friends")
                                    .font(.headline)
                                    .font(.system(size: 20))
                            }
                        Requests()
                            .tabItem {
                                Text("Requests")
                                    .font(.headline)
                                    .font(.system(size: 20))
                            }
                    }
                }
            )
    }
}

// shows incoming friend requests
struct Requests: View {
    @EnvironmentObject var postsManager: PostsManager
    @State private var friendRequests = [(senderUsername: String, status: String)]()
    @State private var acceptRequest = false
    let friendsManager = FriendsManager()
    let currentUserID = Auth.auth().currentUser!.uid
    
    var body: some View {
        Color.cyan.opacity(0.50)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Friend Requests")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.indigo)
                        .padding()
                            
                    if friendRequests.isEmpty {
                        Text("No friend requests")
                            .padding()
                    } else {
                        List(friendRequests, id: \.senderUsername) { request in
                            HStack {
                                Text(request.senderUsername)
                                Spacer()
                                HStack {
                                    Button(action: {
                                        friendsManager.getUID(forUsername: request.senderUsername) { uid in
                                            guard let uid = uid else {
                                                print("Error:  Could not get UID for username: \(request.senderUsername)")
                                                return
                                            }
                                            
                                            friendsManager.respondToFriendRequest(senderID: uid, recipientID: currentUserID,  accepted: true) { success in
                                                if success {
                                                    if let index =  self.friendRequests.firstIndex(where: { $0.senderUsername == request.senderUsername }) {
                                                        self.friendRequests.remove(at: index)
                                                    }
                                                    acceptRequest = true
                                                
                                                } else {
                                                    print("Error:   Failed to respond to friend request")
                                                }
                                            }
                                        }
                                    }, label: {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.indigo)
                                            .font(.system(size: 20))
                                    })
                                    .padding()
                                    
                                    Button(action: {
                                        friendsManager.getUID(forUsername: request.senderUsername) { uid in
                                            guard let uid = uid else {
                                                print("Error:  Could not get UID for username: \(request.senderUsername)")
                                                return
                                            }
                                            
                                            friendsManager.respondToFriendRequest(senderID: uid, recipientID: currentUserID,  accepted: false) { success in
                                                if success {
                                                    if let index = self.friendRequests.firstIndex(where: { $0.senderUsername == request.senderUsername }) {
                                                        self.friendRequests.remove(at: index)
                                                    }
                                                } else {
                                                    print("Error: Failed to respond to friend request")
                                                }
                                            }
                                        }
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.indigo)
                                            .font(.system(size: 20))
                                    })
                                    .padding()
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    friendsManager.getUserFriendRequests(userID: currentUserID) { requests in
                        self.friendRequests = []
                        for request in requests {
                            friendsManager.getUsername(userID: request.senderID) { username in
                                self.friendRequests.append((senderUsername: username, status: request.status))
                            }
                        }
                    }
                }
            )
    }
}

// shows user's current friends list
struct Friends: View {
    @State private var friends = [String]()
    let friendsManager = FriendsManager()
    let currentUserID = Auth.auth().currentUser!.uid
    
    var body: some View {
        Color.cyan.opacity(0.50)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Text("Friends")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.indigo)
                        .padding()
                    
                    if friends.isEmpty {
                        Text("You don't have any friends yet.")
                        Text("Search to add users as friends!")
                    } else {
                        VStack {
                            ForEach(friends, id: \.self) { friend in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .foregroundColor(.white.opacity(0.40))
                                        .frame(width: 300, height: 50)
                                    
                                    Text(friend)
                                        .font(.system(size: 20))
                                        .frame(width: 300, height: 50, alignment: .leading)
                                        .cornerRadius(30)
                                        .padding(.leading, 30)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    friendsManager.getUserFriends(userID: currentUserID) { friendships in
                            self.friends = []
                            for friend in friendships {
                                friendsManager.getUsername(userID: friend) { username in
                                    self.friends.append(username)
                                    }
                            }
                    }
                }
            )
    }
}

struct AccountView: View {  //                  ACCOUNT VIEW
    let friendsManager = FriendsManager()
    let userManager = UserManager()
    @State var username: String = ""
    @State var email: String = ""
    @State var showAlert: Bool = false
    @State var loggedOut: Bool = false
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @StateObject var photosModel: PhotosPickerModel = .init()
    
    
    var body: some View {
        NavigationView {
            Color.cyan.opacity(0.50)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        Text("Account Information")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.indigo)
                            .padding(.bottom, 25)
                        
                        if !photosModel.loadedImage.isEmpty {
                            photosModel.loadedImage.first?.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                
                                
                        } else {
                            PhotosPicker(selection: $photosModel.selectedPhoto,
                                         matching: .any(of: [.images]), photoLibrary: .shared()) {
                                Image(systemName: "person")
//                                    .font(.callout)
                                    .font(.system(size: 100))
                            }
                            Text("Upload profile picture")
                                .padding(.bottom, 25)
                        }
                        HStack {
                            Text("Username: ")
                                .font(.system(size: 20))
                                .foregroundColor(Color.indigo)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .foregroundColor(.white.opacity(0.40))
                                    .frame(width: 200, height: 50)
                                
                                Text("\(username)")
                                    .font(.system(size: 15))
                                    .frame(width: 200, height: 50, alignment: .leading)
                                    .cornerRadius(30)
                                    .padding(.leading, 30)
                            }
                        }
                        .padding()
                        
                        HStack {
                            Text("Email: ")
                                .font(.system(size: 20))
                                .foregroundColor(Color.indigo)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .foregroundColor(.white.opacity(0.40))
                                    .frame(width: 230, height: 50)
                                
                                Text("\(email)")
                                    .font(.system(size: 15))
                                    .frame(width: 230, height: 50, alignment: .leading)
                                    .cornerRadius(30)
                                    .padding(.leading, 30)
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        let currentUserID = Auth.auth().currentUser!.uid
                        friendsManager.getUsername(userID: currentUserID) { username in
                            self.username = username
                        }
                            
                        friendsManager.getEmail(userID: currentUserID) { email in
                            self.email = email
                        }
                    }
                )
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
    }
}

struct HomeView: View {
    @EnvironmentObject var postsManager: PostsManager
    let friendsManager = FriendsManager()
    let userManager = UserManager()
    @State private var animateGradient = false
    @State private var showSearch = false
    @State private var showFriends = false
    @State private var showAccount = false
    @State private var showNewPost = false
    @State private var friends = [String]()
    @State var redrawPreview = false
    @State var posts: [Post] = [Post]()
    @State var liked_posts : [String] = [String]()
    @State var hasPosted: Bool = false
    let currentUserID = Auth.auth().currentUser?.uid
    
    func swapstuff(_ l : String) -> String {
        return l.replacingOccurrences(of: "emma", with: "/")
    }
    
    func username(email: String) -> String {
        var user = ""
        friendsManager.getUsernameFromEmail(email: email) { username in
            user = username
        }
        
        return user
    }

//    CHANGE LIKED POSTS ARRAY TO EMPTY ARRAY WHEN NOTIFICATION COMES UP
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                        LinearGradient(colors: [.blue, .green.opacity(0.30)], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                            .ignoresSafeArea()
                            .onAppear {
                                withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: true)) {
                                        animateGradient.toggle()
                                    }
                            }
                        
                        if hasPosted && !postsManager.posts.isEmpty{
                            // display list of songs
                            List(postsManager.posts, id: \.id){ post in
                                if friends.contains(post.userID) || post.userID == currentUserID {
                                    VStack (alignment: .leading) {
                                        VStack (alignment: .leading) {
                                            Text(post.username)
                                                .foregroundColor(.black.opacity(0.5))
                                        }
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        
                                        let x = swapstuff(post.link)
                                        LinkRow(previewURL: URL(string: x)!, redraw: self.$redrawPreview)
   
                                        HStack {
                                            Button(action: {
                                                if !liked_posts.contains(post.email) {
                                                    postsManager.likePost(post.email)
                                                    liked_posts.append(post.email)
                                                }
                                            })
                                            {

                                                Image(systemName: liked_posts.contains(post.email) ? "heart.fill" : "heart").foregroundColor(.red)
                                            }
                                            Text(post.text).foregroundColor(.black.opacity(0.5))
                                        }
                                    }
                                }
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .environment(\.defaultMinListRowHeight, 200)
                            .refreshable {
                                let _ = postsManager.fetchPosts()
                                friendsManager.getUserFriends(userID: currentUserID!) { friendships in
                                        self.friends = []
                                        for friend in friendships {
                                            self.friends.append(friend)
//                                            friendsManager.getUsername(userID: friend) { username in
//                                                self.friends.append(username)
//                                                }
                                        }
                                }

                            }
                            .frame(maxWidth: 360, maxHeight: 700)
                            .padding(.bottom, 30)
                            .padding(.top,30)
                            .background(.clear)
                        } else {
                            Button(action: {
                                showNewPost.toggle()
                                hasPosted = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .foregroundColor(.white.opacity(0.40))
                                        .frame(width: 300, height: 90)
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.indigo)
                                            .font(.system(size: 45))
                                        
                                        Text("Add your song!")
                                            .foregroundColor(.indigo)
                                            .font(.system(size: 22, weight: .semibold))
                                    }
                                }
                            }
                        }
                    }
                }

            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        showFriends.toggle()
                    }) {
                        Image(systemName: "person.2")
                    }
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .padding()
                    Spacer()
                    
                    Button(action: {
                        showSearch.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .padding()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAccount.toggle()
                    }) {
                        Image(systemName: "person.circle")
                    }
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .padding()
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
            .sheet(isPresented: $showFriends) {
                FriendsView()
            }
            .sheet(isPresented: $showAccount) {
                AccountView().environmentObject(AuthenticationManager())
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView().environmentObject(postsManager)
            }
        }
        .onAppear {
            friendsManager.getUserFriends(userID: currentUserID!) { friendships in
                    self.friends = []
                    for friend in friendships {
                        self.friends.append(friend)
//                        friendsManager.getUsername(userID: friend) { username in
//                            self.friends.append(username)
//                            }
                    }
            }
        }
    }
}
    
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(PostsManager())
    }
}

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject(PostsManager())
    }
}
