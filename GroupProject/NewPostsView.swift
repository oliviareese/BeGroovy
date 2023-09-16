//
//  NewPostsView.swift
//  GroupProject
//
//  Created by Olivia Reese on 4/9/23.
//

import SwiftUI
import Firebase

struct NewPostView: View {
    @EnvironmentObject var postsManager: PostsManager
    @State private var newPost = ""
    @State private var selectedGenre = ""
    @State private var writtenMessage = ""
    @Environment(\.dismiss) var dismiss
    @State private var animateGradient = false
    private var selectText = Text("Select a Genre").foregroundColor(.indigo).font(.system(size: 20, weight: .semibold))
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.80), .green.opacity(0.30)], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack {
                Text("Song of the Day:")
                    .foregroundColor(.indigo.opacity((0.70)))
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(40)
                
                HStack {
                    Text("Link").foregroundColor(.indigo).font(.system(size: 20, weight: .semibold))
                    TextField("Song or Playlist Link", text: $newPost)
                        .padding()
                        .frame(width: 240, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                }
                HStack {
                    
                    VStack {
//                        HStack {
//                            Text("Selected Genre:")
//                                .foregroundColor(.indigo)
//                                .font(.system(size: 20))
//                                .scaledToFill()
//                                .bold()
//
//                            if selectedGenre == "" {
//                                Text("N/A")
//                                    .foregroundColor(.indigo)
//                                    .font(.system(size: 20))
//                            } else {
//                                Text(selectedGenre).scaledToFill()
//                                    .foregroundColor(.indigo)
//                                    .font(.system(size: 20))
//                            }
//                        }
//                        .padding()
                        
                        HStack {
                            
                            Text("Genre").foregroundColor(.indigo).font(.system(size: 20, weight: .medium))
                            
                            TextField("Enter the song's genre", text: $selectedGenre)
                                .padding()
                                .frame(width: 217, height: 50)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                            
//                            DisclosureGroup("\(selectText)") {
//
//                                Button {
//
//                                } label: {
//                                    DisclosureGroup("Pop") {
//                                        Button {
//                                            selectedGenre =     "Dance Pop"
//
//                                        } label: {
//                                            Text("Dance     Pop")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Indie Pop"
//
//                                        } label: {
//                                            Text("Indie Pop")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Synth Pop"
//
//                                        } label: {
//                                            Text("Synth Pop")
//                                        }
//                                    }
//                                }
//                                .scaledToFit()
//                                .cornerRadius(10)
//
//                                Button {
//
//                                } label: {
//
//                                    DisclosureGroup("Rock") {
//                                        Button {
//                                            selectedGenre =     "Classic Rock"
//
//                                        } label: {
//                                            Text("Classic Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Indie Rock"
//
//                                        } label: {
//                                            Text("Indie Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Alternative Rock"
//
//                                        } label: {
//                                            Text("Alternative Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Beach Rock"
//
//                                        } label: {
//                                            Text("Beach Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Progressive Rock"
//
//                                        } label: {
//                                            Text("Progressive Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Punk Rock"
//
//                                        } label: {
//                                            Text("Punk Rock")
//                                        }
//
//                                        Button {
//                                            selectedGenre =     "Funk Rock"
//
//                                        } label: {
//                                            Text("Funk Rock")
//                                        }
//                                    }
//                                }
//                                .scaledToFit()
//                                .cornerRadius(10)
//
//                                Button {
//
//                                } label: {
//                                    DisclosureGroup("EDM") {
//                                        Button {
//                                            selectedGenre = "House"
//                                        } label: {
//                                            Text("House")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Future Bass"
//                                        } label: {
//                                            Text("Future Bass")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Trap"
//                                        } label: {
//                                            Text("Trap")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Dubstep"
//                                        } label: {
//                                            Text("Dubstep")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Techno"
//                                        } label: {
//                                            Text("Techno")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Drum & Bass"
//                                        } label: {
//                                            Text("Drum & Bass")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Hardstyle"
//                                        } label: {
//                                            Text("Hardstyle")
//                                        }
//                                    }
//                                }
//                                .scaledToFit()
//                                .cornerRadius(10)
//
//                                Button {
//                                    //                                selectedGenre = "Rap"
//                                } label: {
//                                    DisclosureGroup("Rap") {
//                                        Button {
//                                            selectedGenre = "Old school"
//                                        } label: {
//                                            Text("Old School")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Drill"
//                                        } label: {
//                                            Text("Drill")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "West Coast"
//                                        } label: {
//                                            Text("West Coast")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "East Coast"
//                                        } label: {
//                                            Text("East Coast")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Funk"
//                                        } label: {
//                                            Text("Funk")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Soul"
//                                        } label: {
//                                            Text("Soul")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Southern"
//                                        } label: {
//                                            Text("Southern")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Midwest"
//                                        } label: {
//                                            Text("Midwest")
//                                        }
//                                    }
//                                }
//
//                                Button {
//
//                                } label: {
//                                    DisclosureGroup("Country") {
//
//                                        Button {
//                                            selectedGenre = "Classic Country"
//                                        } label: {
//                                            Text("Classic Country")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Alternative Country"
//                                        } label: {
//                                            Text("Alternative Country")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Australian Country"
//                                        } label: {
//                                            Text("Australian Country")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Bluegrass"
//                                        } label: {
//                                            Text("Bluegrass")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Western Swing"
//                                        } label: {
//                                            Text("Western Swing")
//                                        }
//
//                                        Button {
//                                            selectedGenre = "Honk Tonk"
//                                        } label: {
//                                            Text("Honk Tonk")
//                                        }
//                                    }
//                            }
//                            .scaledToFit()
//                            .cornerRadius(10)
//                            .padding()
                        //}
                    }
                    }
                    
                }.padding(10)
                
//                HStack {
                    TextField("Add a message", text: $writtenMessage)
                        .padding()
                        .frame(width: 280, height: 80)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    Button {
                        
                        var urltype = ""
                        
                        if newPost.contains("sets") || newPost.contains("playlist"){
                            urltype = "playlist"
                        } else {
                            urltype = "song"
                        }
                        
                        if selectedGenre != "" && newPost != "" && (newPost.contains("spotify") ||
                                                                    newPost.contains("apple") ||
                                                                    newPost.contains("soundcloud")) {
                            
                            self.postsManager.addPost(link: newPost.replacingOccurrences(of: "/", with: "emma"), genre: selectedGenre, linktype: urltype, text: writtenMessage)
                            dismiss()
                        }
                        
                    } label: {
                        Text("Share")
                            .bold()
                            .foregroundColor(.indigo)
                            .font(.system(size: 25))
//                            .scaledToFill()
                        Image(systemName: "arrow.right")
//                            .scaledToFit()
                            .foregroundColor(.indigo)
                            .font(.system(size: 20))
                            
                    }
                    
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .padding(10)
                    
//                }
            }
            .frame(width: 300, height: 100, alignment: .leading)
            
        }
    }
}

struct ListSelectionStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 60, height: 40)
            .background(configuration.isPressed ? Color.gray : Color.clear)
            .cornerRadius(10)
    }
}

struct NewPostView_Preview: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
