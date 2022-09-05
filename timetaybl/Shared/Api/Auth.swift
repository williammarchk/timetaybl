//
//  CalendarApi.swift
//  timetaybl
//
//  Created by MACKE, Mats on 05.09.22.
//

import Foundation
import OAuth2

class GoogleLoader: OAuth2DataLoader {
    
    let baseURL = URL(string: "https://www.googleapis.com")!
    
    public init() {
        let oauth = OAuth2CodeGrant(settings: [
            "client_id": "184149248061-u0pqmh6q7gkheoffs3pelf111qhdaaqk.apps.googleusercontent.com",
            "client_secret": "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",
            "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "scope": "https://www.googleapis.com/auth/calendar.events.readonly https://www.googleapis.com/auth/calendar.readonly",
            "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
        ])
        //oauth.authConfig.authorizeEmbedded = true
        oauth.logger = OAuth2DebugLogger(.debug)
        super.init(oauth2: oauth, host: "https://www.googleapis.com")
        alsoIntercept403 = true
    }
    
    /** Perform a request against the API and return decoded JSON or an Error. */
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                var profile = [String: String]()
                if let name = dict["displayName"] as? String {
                    profile["name"] = name
                }
                if let avatar = (dict["image"] as? OAuth2JSON)?["url"] as? String {
                    profile["avatar_url"] = avatar
                }
                if let error = (dict["error"] as? OAuth2JSON)?["message"] as? String {
                    DispatchQueue.main.async {
                        callback(nil, OAuth2Error.generic(error))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        callback(profile, nil)
                    }
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    callback(nil, error)
                }
            }
        }
    }
    
    func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "plus/v1/people/me", callback: callback)
    }
}
