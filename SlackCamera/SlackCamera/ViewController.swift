//
//  ViewController.swift
//  SlackCamera
//

import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.openPicker()
    }
}

extension ViewController /* private functions */ {
    private func openPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        
        self.show(picker, sender: self)
    }
    
    private func post(image: UIImage) {
        Slack.post(image: image, filename: "slack_camera") { [weak self] error in
            if let error = error {
                self?.showPostError(error)
            } else {
                self?.openPicker()
            }
        }
    }
    
    private func showPostError(_ error: Error) {
        let alert = UIAlertController(title: "画像の投稿に失敗しました", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.openPicker()
        }
        alert.addAction(action)
        self.show(alert, sender: self)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            guard let mediaType = info[UIImagePickerControllerMediaType] as? String, mediaType == "public.image" else {
                return
            }
            
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            
            self.post(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.openPicker()
        }
    }
}
