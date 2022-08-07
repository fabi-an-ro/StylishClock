//
//  SegmentDot.swift
//
//  Created by Fabian Rottensteiner on 04.08.22.
//

#if canImport(UIKit)

import UIKit

enum SegmentState {
    case on, off
}

@available(iOS 13.0, *)
class SegmentDot: UIView {
    // MARK: - Properties

    var onColor: UIColor
    var offColor: UIColor

    var state: SegmentState = .off {
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
    
    init(onColor: UIColor, offColor: UIColor) {
        self.onColor = onColor
        self.offColor = offColor
        
        super.init(frame: .zero)
        
        self.backgroundColor = offColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = layer.bounds.width / 2
    }
}

#endif
