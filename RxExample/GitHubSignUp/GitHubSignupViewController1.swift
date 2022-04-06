//
//  GitHubSignupViewController1.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class GitHubSignupViewController1: ViewController {

    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var userNameValidationLabel: UILabel!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordValidationLabel: UILabel!
    
    @IBOutlet private weak var repeatedPasswordTextField: UITextField!
    @IBOutlet private weak var repeatedPasswordValidationLabel: UILabel!
    
    @IBOutlet private weak var signupOutlet: UIButton!
    @IBOutlet private weak var signingUpOulet: UIActivityIndicatorView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let input = GithubSignUpViewModelInput(
            userName: userNameTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            repeatedPassword: repeatedPasswordTextField.rx.text.orEmpty.asObservable(),
            loginTaps: signupOutlet.rx.tap.asObservable()
        )

        let dependency = GithubSignUpViewModelDependency(
            API: GitHubDefaultAPI.sharedAPI,
            validationService: GitHubDefaultValidationService.sharedValidationService,
            wireframe: DefaultWireframe.shared
        )

        let output = GithubSignupViewModel1().transform(input: input, dependency: dependency)

        output.signupEnabled
            .subscribe(onNext: { [weak self] valid in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        output.validatedUsername
            .bind(to: userNameValidationLabel.rx.validationResult)
            .disposed(by: disposeBag)

        output.validatedPassword
            .bind(to: passwordValidationLabel.rx.validationResult)
            .disposed(by: disposeBag)

        output.validatedPasswordRepeated
            .bind(to: repeatedPasswordValidationLabel.rx.validationResult)
            .disposed(by: disposeBag)

        output.signingIn
            .bind(to: signingUpOulet.rx.isAnimating)
            .disposed(by: disposeBag)

        output.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)

        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
    }
}
