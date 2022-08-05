//
//  ClockView.swift
//  Clock
//
//  Created by Fabian Rottensteiner on 04.08.22.
//

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
public class ClockView: UIView {
    // MARK: - Properties

    let dotDiameter: CGFloat = 5.0
    let fontSize: CGFloat = 50.0

    let dispatchQueue = DispatchQueue(label: "clock", qos: .background, target: .global(qos: .background))

    private lazy var segmentDots: [Int: SegmentDot] = {
        var dots = [Int: SegmentDot]()

        for i in 0..<60 {
            dots[i] = SegmentDot()
        }

        return dots
    }()

    private lazy var clockLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fontSize)

        label.clipsToBounds = true

        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        setupSegmentDots()
    }

    // MARK: - Private

    private func setupView() {
        self.addSubview(clockLabel)

        NSLayoutConstraint.activate([
            clockLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            clockLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupSegmentDots() {
        let radius: CGFloat = layer.bounds.height / 2 - 10.0

        let range = -CGFloat.pi / 2 ... CGFloat.pi * 1.5

        for idx in 0..<60 {
            let angle = range.lowerBound + CGFloat(idx) / CGFloat(60) * (range.upperBound - range.lowerBound)
            let offset = CGPoint(x: radius * cos(angle), y: radius * sin(angle))

            segmentDots[idx]!.translatesAutoresizingMaskIntoConstraints = false // swiftlint:disable:this force_unwrapping

            addSubview(segmentDots[idx]!) // swiftlint:disable:this force_unwrapping

            NSLayoutConstraint.activate([
                segmentDots[idx]!.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x), // swiftlint:disable:this force_unwrapping
                segmentDots[idx]!.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y), // swiftlint:disable:this force_unwrapping
                segmentDots[idx]!.heightAnchor.constraint(equalToConstant: dotDiameter), // swiftlint:disable:this force_unwrapping
                segmentDots[idx]!.widthAnchor.constraint(equalToConstant: dotDiameter) // swiftlint:disable:this force_unwrapping
            ])
        }
    }

    public func start() {
        let calendar = Calendar.current

        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let date = Date()

            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let seconds = calendar.component(.second, from: date)

            DispatchQueue.main.async {
                self.clockLabel.text = "\(hour):\(minutes)"

                self.segmentDots.forEach {
                    if $0.key <= seconds {
                        $0.value.state = .on
                    } else {
                        $0.value.state = .off
                    }
                }
            }
        }

        RunLoop.current.add(timer, forMode: .default)
    }
}

#endif
