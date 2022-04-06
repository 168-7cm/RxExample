//
//  GithubSignupViewModel1.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

struct GithubSignUpViewModelInput {
    let userName: Observable<String>
    let password: Observable<String>
    let repeatedPassword: Observable<String>
    let loginTaps: Observable<Void>
}

struct GithubSignUpViewModelOutput {
    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>
    let signupEnabled: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>
}

struct GithubSignUpViewModelDependency {
    let API: GitHubAPI
    let validationService: GitHubValidationService
    let wireframe: Wireframe
}

final class GithubSignupViewModel1 {

    func transform(input: GithubSignUpViewModelInput, dependency: GithubSignUpViewModelDependency) -> GithubSignUpViewModelOutput {
        let validatedUserName = input.userName
            .flatMapLatest { userName in
                return dependency.validationService.validateUserName(userName)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn(.failed(message: "Error contacting server"))
            }

        let validatedPassword = input.password
            .map { password in
                return dependency.validationService.validatePassword(password)
            }
            .share(replay: 1)

        let validatedPasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: dependency.validationService.validateRepeatPassword(_:repeatedPassword:))
            .share(replay: 1)

        let signingIn = ActivityIndicator()
        let signingInObservable = signingIn.asObservable()
        let usernameAndPassword = Observable.combineLatest(input.userName, input.password) { (username: $0, password: $1) }

        let signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { pair in
                return dependency.API.signUp(pair.username, password: pair.password)
                    .observe(on:MainScheduler.instance)
                    .catchAndReturn(false)
                    .trackActivity(signingIn)
            }
            .flatMapLatest { loggedIn -> Observable<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
                return dependency.wireframe.promptFor(message, cancelAction: "OK", actions: [])
                // propagate original value
                    .map { _ in
                        loggedIn
                    }
            }
            .share(replay: 1)

        let signupEnabled = Observable.combineLatest(
            validatedUserName,
            validatedPassword,
            validatedPasswordRepeated,
            signingIn.asObservable()
        )   { username, password, repeatPassword, signingIn in
            username.isValid &&
            password.isValid &&
            repeatPassword.isValid &&
            !signingIn
        }
        .distinctUntilChanged()
        .share(replay: 1)

        return GithubSignUpViewModelOutput(validatedUsername: validatedUserName, validatedPassword: validatedPassword, validatedPasswordRepeated: validatedPasswordRepeated, signupEnabled: signupEnabled, signedIn: signedIn, signingIn: signingInObservable)
    }
}
