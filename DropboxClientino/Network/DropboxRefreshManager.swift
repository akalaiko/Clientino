//
//  DropboxRefreshManager.swift
//  DropboxClientino
//
//  Created by Tim on 06.09.2023.
//

import Foundation
import SwiftyDropbox

protocol TokenRefreshProtocol {
    func refreshToken(completion: @escaping (Error?) -> Void)
}

final class DropboxRefreshManager: TokenRefreshProtocol {
    
    private var expirationTimer: Timer?
    
    deinit {
        expirationTimer?.invalidate()
    }
    
    func refreshToken(completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "https://api.dropbox.com/oauth2/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "refresh_token=\(Constants.refreshToken)",
            "grant_type=\(Constants.grantType)",
            "client_id=\(Constants.appKey)",
            "client_secret=\(Constants.appSecret)"
        ].joined(separator: "&")
        
        request.httpBody = params.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self, let data, error == nil else {
                completion(error)
                return
            }
            
            do {
                guard let decodedResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = decodedResponse["access_token"] as? String,
                      let expiresIn = decodedResponse["expires_in"] as? TimeInterval
                else {
                    completion(error)
                    return
                }
                
                DropboxClientsManager.authorizedClient = DropboxClient(accessToken: token)
                
                self.expirationTimer?.invalidate()
                self.expirationTimer = Timer.scheduledTimer(withTimeInterval: expiresIn, repeats: false) { [weak self] _ in
                    guard let self else { return }
                    DropboxClientsManager.authorizedClient = nil
                    self.refreshToken { error in
                        if let error {
                            completion(error)
                        }
                    }
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
        task.resume()
    }
}

