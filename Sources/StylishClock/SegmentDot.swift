//
//  SegmentDot.swift
//  Clock
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

    var state: SegmentState = .off {
        didSet {
            switch state {
            case .off:
                self.backgroundColor = .secondarySystemBackground
            case .on:
                self.backgroundColor = .label
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .secondarySystemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = layer.bounds.width / 2
    }

    // MARK: - Private
}

#endif
