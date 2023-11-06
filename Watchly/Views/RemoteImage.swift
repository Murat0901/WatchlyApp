//
//  RemoteImage.swift
//  Watchly
//
//  Created by Murat Menzilci on 2/2/22.
//

import SwiftUI
import Firebase
import Foundation
import FirebaseStorage

// MARK: - Custom image view class to load images from web
struct RemoteImage: View {
    
    @ObservedObject var assetModel: AssetModel
    @State private var image: UIImage = UIImage()
    let contentMode: ContentMode
    let placeholder: String
    
    /// Initializer the `RemoteImage` with custom parameters required for fetching image data
    /// - Parameters:
    ///   - assetModel: image downloader model
    ///   - contentMode: content mode for the image
    ///   - placeholder: a placeholder image name while the remote image is downloaded
    init(assetModel: AssetModel, contentMode: ContentMode = .fill, placeholder: String = "placeholder") {
        self.assetModel = assetModel
        self.contentMode = contentMode
        self.placeholder = placeholder
        self.image = UIImage(named: placeholder)!
        self.assetModel.fetchAsset()
    }
    
    // MARK: - Main rendering function
    public var body: some View {
        Image(uiImage: image).resizable().aspectRatio(contentMode: contentMode)
            .onReceive(assetModel.$image) { downloadedImage in
                self.image = downloadedImage ?? UIImage(named: placeholder)!
            }
    }
}

// MARK: - Custom image observable object
class AssetModel: ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var image: UIImage?
    
    /// Init the model with image location
    var imageLocation: String
    init(path: String) { imageLocation = path }
    
    /// Fetch image asset
    func fetchAsset() {
        if image == nil && !imageLocation.contains("header-image") {
            if let documentsImage = loadImageFromDocumentDirectory(fileName: imageLocation) {
                image = documentsImage
            } else {
                let size = Int64(1 * 1024 * 1024)
                Storage.storage().reference().child(imageLocation).getData(maxSize: size) { data, _ in
                    DispatchQueue.main.async {
                        if let imageData = data, let downloadedImage = UIImage(data: imageData) {
                            self.saveImageInDocumentDirectory(image: downloadedImage, fileName: self.imageLocation)
                            self.image = downloadedImage
                        }
                    }
                }
            }
        }
    }
    
    /// Save image to the documents folder
    private func saveImageInDocumentDirectory(image: UIImage, fileName: String) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
        }
    }
    
    /// Load image from documents folder
    public func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
}
