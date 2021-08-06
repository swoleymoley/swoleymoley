import AuthenticationServices
import Alamofire
import UIKit
import SwiftUI
import StravaZpot_Swift
import Foundation

class StravaLoginViewController: UIViewController {
    private var authSession: ASWebAuthenticationSession?
    private let clientId: String = "67811"
    private let urlScheme: String = "swoleymoley"
    private let fallbackUrl: String = "swoleymoley.com"
    private let clientSecret: String = "96b2106b4ce0ef412768a90e7032c2487d8014e6"
    private var access_token: String = "None"
    
    var activity_name: String
    var activity_description: String
    var activity_elapsed_time: Int
    var activity_date: String
    
    init(workout: Workout?){
        self.activity_name = workout?.getMainLift() ?? ""
        self.activity_description = workout?.getWorkoutDescription() ?? ""
        self.activity_elapsed_time = 300 * (workout?.exercises.count ?? 0)
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.activity_date = iso8601DateFormatter.string(from: workout?.date ?? Date())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()

      let button = UIButton(frame: CGRect(x: 10, y: 10, width: 300, height: 50))
      button.backgroundColor = .systemBlue
      button.setTitle("Push to Strava", for: .normal)
      button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

      self.view.addSubview(button)
    }

    @objc func buttonAction(sender: UIButton!) {
      presentStravaAuthentication()
        print("Button tapped")
        print(self.access_token)
    }
    
    private func getCode(from url: URL?) -> String? {
        print("getcode")
        guard let url = url?.absoluteString else { return nil }
        
        let urlComponents: URLComponents? = URLComponents(string: url)
        let code: String? = urlComponents?.queryItems?.filter { $0.name == "code" }.first?.value
        
        return code
    }
    
    func presentStravaAuthentication() {
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(fallbackUrl)&response_type=code&approval_prompt=auto&scope=activity:write"
        guard let authenticationUrl = URL(string: url) else { return }
        print("presentStravaAuthentication")
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)://") { [weak self] url, error in
            if let error = error {
                print(error)
            } else {
                if let code = self?.getCode(from: url) {
                    print("here is the code")
                    print(code)
                    self?.requestStravaTokens(with: code)
                    
                }
            }
        }

        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    private func postStravaActivity(access_token: String) {
        print("postActivity")
        let parameters: [String: Any] = ["name": self.activity_name, "type": "WeightTraining", "start_date_local": self.activity_date, "elapsed_time": self.activity_elapsed_time, "description": self.activity_description, "distance": 0, "trainer": "SwoleyMoley", "commute": 0]
        Alamofire.request("https://www.strava.com/api/v3/activities", method: .post, parameters: parameters, headers: ["Authorization": "Bearer \(access_token)"]).response { response in
            guard let data = response.data else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(json)
                        }

                }
    }
    
    private func requestStravaTokens(with code: String) {
        print("requestStravaTokens")
        let parameters: [String: Any] = ["client_id": clientId, "client_secret": clientSecret, "code": code, "grant_type": "authorization_code"]

        Alamofire.request("https://www.strava.com/oauth/token", method: .post, parameters: parameters).response { response in
            guard let data = response.data else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(json)
                if let json = json as? [String: Any], let access_token = json["access_token"] as? String {
                    print(access_token)
                    self.access_token = access_token
                    print("token set")
                    self.postStravaActivity(access_token: access_token)
                        }

                }
            }
        }
}


extension StravaLoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows[0]
    }

}


struct StravaLoginView: UIViewControllerRepresentable {
    @Binding var workout: Workout?
    
    func makeUIViewController(context: Context) -> StravaLoginViewController {
        print("makeUIViewController")
        return StravaLoginViewController(workout: workout)
    }

    func updateUIViewController(_ uiViewController: StravaLoginViewController, context: Context) {
    }
}


