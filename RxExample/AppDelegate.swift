//
//  AppDelegate.swift
//  RxExample
//
//  Created by kou yamamoto on 2022/04/05.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "GitHubSignup1", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GitHubSignUp") as! GitHubSignupViewController1
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

