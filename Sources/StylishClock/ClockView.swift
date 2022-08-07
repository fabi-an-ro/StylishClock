//
//  ClockView.swift
//
//  Created by Fabian Rottensteiner on 04.08.22.
//

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
public class ClockView: UIView {
    // MARK: - Properties

    public var dotDiameter: CGFloat = 5.0

    public var fontSize: CGFloat = 50.0 {
        didSet {
            clockLabel.font = UIFont.systemFont(ofSize: fontSize)
        }
    }

    public var textColor: UIColor = UIColor.label {
        didSet {
            clockLabel.textColor = textColor
        }
    }

    public var dotsOffColor: UIColor = UIColor.secondarySystemBackground {
        didSet {
            segmentDots.forEach {
                $0.value.offColor = dotsOffColor
            }
        }
    }

    public var dotsOnColor: UIColor = UIColor.label {
        didSet {
            segmentDots.forEach {
                $0.value.onColor = dotsOnColor
            }
        }
    }
    
    public var timeFormat: TimeFormat = .twentyfourHours

    let dispatchQueue = DispatchQueue(label: "clock", qos: .background, target: .global(qos: .background))
    
    let dateFormatter = DateFormatter()

    var timer: Timer?

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

        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: fontSize)

        label.textAlignment = .center
        label.numberOfLines = 0

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

    // MARK: - Public

    public func start() {
        if let timer = timer, timer.isValid {
            return
        }

        let calendar = Calendar.current

        updateClock(with: calendar)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateClock(with: calendar)
        }

        RunLoop.current.add(timer!, forMode: .default)
    }

    public func stop() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
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
        let radius: CGFloat = min(layer.bounds.height / 2 - CGFloat(dotDiameter) / 2, layer.bounds.width / 2 - CGFloat(dotDiameter) / 2)

        let range = -CGFloat.pi / 2 ... CGFloat.pi * 1.5

        for idx in 0..<60 {
            let angle = range.lowerBound + CGFloat(idx) / CGFloat(60) * (range.upperBound - range.lowerBound)
            let offset = CGPoint(x: radius * cos(angle), y: radius * sin(angle))

            segmentDots[idx]!.translatesAutoresizingMaskIntoConstraints = false

            addSubview(segmentDots[idx]!)

            NSLayoutConstraint.activate([
                segmentDots[idx]!.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                segmentDots[idx]!.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y),
                segmentDots[idx]!.heightAnchor.constraint(equalToConstant: dotDiameter),
                segmentDots[idx]!.widthAnchor.constraint(equalToConstant: dotDiameter)
            ])
        }
    }

    private func updateClock(with calendar: Calendar) {
        let date = Date()

        let seconds = calendar.component(.second, from: date)
        
        let timeString = dateFormatter.string(from: date, with: timeFormat)

        DispatchQueue.main.async {
            self.clockLabel.text = timeString

            self.segmentDots.forEach {
                if $0.key <= seconds {
                    $0.value.state = .on
                } else {
                    $0.value.state = .off
                }
            }
        }
    }
}

#endif
