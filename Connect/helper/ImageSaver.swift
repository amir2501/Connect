//  ImageSaver.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import UIKit
import Photos
import AudioToolbox

class ImageSaver {
    
    /// Save image from asset name
    func saveImage(named imageName: String, in viewController: UIViewController) {
        guard let image = UIImage(named: imageName) else {
            print("❌ Image not found: \(imageName)")
            return
        }
        presentSaveAlert(for: image, in: viewController)
    }
    
    /// Save image from URL
    func saveImage(from url: URL, in viewController: UIViewController) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to download image from URL: \(url)")
                return
            }
            DispatchQueue.main.async {
                self.presentSaveAlert(for: image, in: viewController)
            }
        }.resume()
    }
    
    /// Confirmation alert before saving
    private func presentSaveAlert(for image: UIImage, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Save Image",
            message: "Do you want to save this image to your photo library?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.attemptSave(image: image)
        })
        
        viewController.present(alert, animated: true)
    }
    
    func saveImageUrl(from url: URL, in viewController: UIViewController) {
        saveImage(from: url, in: viewController)
    }
    
    /// Attempt to save image with permission checks
    private func attemptSave(image: UIImage) {
        let saveBlock = {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("✅ Image saved to photo library")
            
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
            AudioServicesPlaySystemSound(1108) // Shutter sound
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            saveBlock()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async { saveBlock() }
                } else {
                    print("❌ Photo library access denied")
                }
            }
        default:
            print("❌ Photo library access denied or restricted")
        }
    }
}
