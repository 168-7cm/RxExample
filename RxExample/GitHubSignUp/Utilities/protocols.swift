//
//  protocols.swift
//  RxExample
//
//  Created by kou yamamoto on 2022/04/05.
//

import RxSwift
import RxCocoa

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

protocol GitHubAPI {
    func userNameAvailable(_ userName: String) -> Observable<Bool>
    func signUp(_ userName: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUserName(_ userName: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}
