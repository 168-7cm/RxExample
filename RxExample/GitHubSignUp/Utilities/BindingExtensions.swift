//
//  BindingExtensions.swift
//  RxExample
//
//  Created by kou yamamoto on 2022/04/06.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: 何でこれに準拠しているのか謎すぎるので考える
extension ValidationResult: CustomStringConvertible {

    var description: String {
        switch self {
        case .ok(let message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating"
        case .failed(let message):
            return message
        }
    }
}

struct ValidationColors {

    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension ValidationResult {

    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}

// TODO: Binderの内部構造についても調べる
extension Reactive where Base: UILabel {

    var validationResult2: Binder<ValidationResult> {
        return Binder(base, binding: { (base, validationResult) -> Void in
            base.textColor = validationResult.textColor
            base.text = validationResult.description
        })
    }

    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
