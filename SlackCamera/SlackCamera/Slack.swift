//
//  Slack.swift
//  SlackCamera
//

import Foundation
import UIKit

class Slack {
    init() {
    }
    
    class func post(image: UIImage, filename: String, completion: @escaping (Error?) -> Void) {
        guard let resizedImage = resize(image: image) else {
            return
        }
        
        guard let jpegData = UIImageJPEGRepresentation(resizedImage, 1.0) else {
            return
        }
        
        guard let plistUrl = Bundle.main.url(forResource: "slack", withExtension: "plist") else {
            return
        }
        
        guard let plist = NSDictionary(contentsOf: plistUrl) else {
            return
        }
        
        guard let channelID = plist["channel_id"] as? String else {
            return
        }
        
        guard let token = plist["bot_token"] as? String else {
            return
        }
        
        guard var components = URLComponents(string: "https://slack.com/api/files.upload") else {
            return
        }
        
        components.queryItems = [URLQueryItem(name: "token", value: token),
                                 URLQueryItem(name: "channels", value: channelID)]
        
        guard let url = components.url else {
            return
        }
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let boundary:String = "---------------------------\(uniqueId)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = headers
        
        let body = self.httpBody(jpegData, fileName: filename, boundary: boundary)
        
        let session = Foundation.URLSession(configuration: urlConfig)
        let task = session.uploadTask(with: request, from: body, completionHandler: { (data, response, error) in
            completion(error)
        })
        
        task.resume()
    }
}

extension Slack {
    class private func httpBody(_ fileAsData: Data, fileName: String, boundary: String) -> Data {
        var data = "--\(boundary)\r\n".data(using: .utf8)!
        data += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
        data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
        data += "\r\n".data(using: .utf8)!
        data += fileAsData
        data += "\r\n".data(using: .utf8)!
        data += "--\(boundary)--\r\n".data(using: .utf8)!
        
        return data
    }
    
    class private func resize(image: UIImage) -> UIImage? {
        let max: CGFloat = 1000
        let widthRatio = max / image.size.width
        let heightRatio = max / image.size.height
        let ratio = min(widthRatio, heightRatio)
        let size = CGSize(width: ceil(image.size.width * ratio), height: ceil(image.size.height * ratio))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
