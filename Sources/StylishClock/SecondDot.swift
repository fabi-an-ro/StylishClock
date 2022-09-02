//
//  SecondDot.swift
//
//  Created by Fabian Rottensteiner on 04.08.22.
//

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
class SecondDot: UIView, SecondProtocol {
    // MARK: - Properties

    var onColor: UIColor
    var offColor: UIColor

    var state: SecondState = .off {
        didSet {
            switch state {
            case .off:
                self.backgroundColor = offColor
            case .on:
                self.backgroundColor = onColor
            }
        }
    }

    // MARK: - Init
    
    required init(onColor: UIColor, offColor: UIColor) {
        self.onColor = onColor
        self.offColor = offColor
        
        super.init(frame: .zero)
        
        self.backgroundColor = offColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override func layoutSubviews() {
        super.layoutSubviews()

        setupView()
    }

    // MARK: - Private

    func setupView() {
        layer.cornerRadius = layer.bounds.width / 2
    }
}

#endif
