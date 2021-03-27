//
//  RecoverableViewState.swift
//  SkeletonView
//
//  Created by Juanpe Catalán on 13/05/2018.
//  Copyright © 2018 SkeletonView. All rights reserved.
//

import UIKit

struct RecoverableViewState {
    var backgroundColor: UIColor?
    var cornerRadius: CGFloat
    var clipToBounds: Bool
    var isUserInteractionsEnabled: Bool

    init(view: UIView) {
        backgroundColor = view.backgroundColor
        clipToBounds = view.layer.masksToBounds
        cornerRadius = view.layer.cornerRadius
        isUserInteractionsEnabled = view.isUserInteractionEnabled
    }
}

struct RecoverableTextViewState {
    var textColor: UIColor?

    init(view: UILabel) {
        textColor = view.textColor
    }

    init(view: UITextView) {
        textColor = view.textColor
    }
}

struct RecoverableTextFieldState {
    var textColor: UIColor?
    var placeholder: String?

    init(view: UITextField) {
        textColor = view.textColor
        placeholder = view.placeholder
    }
}

struct RecoverableImageViewState {
    var image: UIImage?

    init(view: UIImageView) {
        image = view.image
    }
}

struct RecoverableButtonViewState {
    var title: String?

    init(view: UIButton) {
        title = view.titleLabel?.text
    }
}
