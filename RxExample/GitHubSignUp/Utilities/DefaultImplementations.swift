//
//  DefaultImplementations.swift
//  RxExample
//
//  Created by kou yamamoto on 2022/04/05.
//

import Foundation
import RxSwift

final class GitHubDefaultValidationService: GitHubValidationService {

    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)

    private let API: GitHubAPI
    private let minPasswordCount = 5

    init(API: GitHubAPI) {
        self.API = API
    }

    func validateUserName(_ userName: String) -> Observable<ValidationResult> {

        if userName.isEmpty { return Observable.just(.empty) }

        // 調べる
        if userName.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return Observable.just(.failed(message: "Username can only contain numbers or digits"))
        }

        let loadingValue = ValidationResult.validating

        return API.userNameAvailable(userName)
            .map { available in
                return available ? .ok(message: "userName available") : .failed(message: "userName already taken")
            }
            .startWith(loadingValue)
    }

    func validatePassword(_ password: String) -> ValidationResult {

        if password.count == 0 { return .empty }

        return password.count > minPasswordCount ? .ok(message: "Password acceptable") : .failed(message: "Password must be at least \(minPasswordCount) characters")
    }

    func validateRepeatPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        
        if repeatedPassword.count == 0 { return .empty }

        return repeatedPassword == password ? .ok(message: "Password repeated") : .failed(message: "Password different")
    }
}

class GitHubDefaultAPI: GitHubAPI {

    static let sharedAPI = GitHubDefaultAPI(URLSession: Foundation.URLSession.shared)

    private let URLSession: Foundation.URLSession

    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }

    func userNameAvailable(_ userName: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(userName.URLEscaped)")!
        let request = URLRequest(url: url)
        return URLSession.rx.response(request: request)
            .map { pair in
                return pair.response.statusCode == 404
            }
            .catchAndReturn(false)
    }

    func signUp(_ userName: String, password: String) -> Observable<Bool> {
        let signUpResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signUpResult).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}

extension String {
    var URLEscaped: String {
        // If the URL contains a username and password, the host component is the component after the @ sign.
        // For example, in the URL http://username:password@www.example.com/index.html, the host component is www.example.com.
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
