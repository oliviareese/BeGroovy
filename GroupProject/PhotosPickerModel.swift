//
//  PhotosPickerModel.swift
//  GroupProject
//
//  Created by Annemarie Peek on 5/7/23.
//

import Foundation
import SwiftUI
import PhotosUI
import _PhotosUI_SwiftUI
import Firebase

struct MediaFile: Identifiable {
    var id: String = UUID().uuidString
    var image: Image
    var data: Data
}

class PhotosPickerModel: ObservableObject {
    @Published var loadedImage: [MediaFile] = []
    
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            if let selectedPhoto {
                processPhoto(photo: selectedPhoto)
            }
        }
    }
    
    func processPhoto(photo: PhotosPickerItem) {
        photo.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.sync {
                switch result {
                case .success(let data):
                    if let data, let image = UIImage(data: data) {
                        self.loadedImage.append(.init(image: Image(uiImage: image), data: data))
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
    }
    
}
