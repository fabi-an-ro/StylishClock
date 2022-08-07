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

    private var dotDiameter: CGFloat?

    private var font: UIFont? {
        didSet {
            clockLabel.font = font
        }
    }

    /// UIColor which defines the textColor of the time label.
    public var timeLabelTextColor: UIColor {
        didSet {
            clockLabel.textColor = timeLabelTextColor
        }
    }
    
    /// UIColor which defines the textColor of the am/pm label
    public var amPmLabelTextColor: UIColor {
        didSet {
            amPmLabel.textColor = amPmLabelTextColor
        }
    }

    /// UIColor which defines the color of the second-dots when in off-state
    public var dotsOffColor: UIColor {
        didSet {
            segmentDots.forEach {
                $0.value.offColor = dotsOffColor
            }
        }
    }

    /// UIColor which defines the color of the second-dots when in on-state
    public var dotsOnColor: UIColor {
        didSet {
            segmentDots.forEach {
                $0.value.onColor = dotsOnColor
            }
        }
    }
    
    /// This variable defines the time format of the clock
    public var timeFormat: TimeFormat = .twentyfourHours

    let dispatchQueue = DispatchQueue(label: "clock", qos: .background, target: .global(qos: .background))
    
    let dateFormatter = DateFormatter()

    var timer: Timer?

    private lazy var segmentDots: [Int: SegmentDot] = {
        var dots = [Int: SegmentDot]()

        for i in 0..<60 {
            dots[i] = SegmentDot(onColor: dotsOnColor, offColor: dotsOffColor)
        }

        return dots
    }()

    private lazy var clockLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = timeLabelTextColor
        label.font = font

        label.textAlignment = .center

        return label
    }()
    
    private lazy var amPmLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = amPmLabelTextColor
        
        label.textAlignment = .center
        
        return label
    }()

    // MARK: - Init
    
    public convenience init(timeFormat: TimeFormat) {
        self.init(timeFormat: timeFormat,
                  timeLabelTextColor: .label,
                  amPmLabelTextColor: .secondaryLabel,
                  dotsOffColor: .secondarySystemBackground,
                  dotsOnColor: .label)
    }
    
    public init(timeFormat: TimeFormat, timeLabelTextColor: UIColor?, amPmLabelTextColor: UIColor?, dotsOffColor: UIColor?, dotsOnColor: UIColor?) {
        self.timeFormat = timeFormat
        self.timeLabelTextColor = timeLabelTextColor ?? .label
        self.amPmLabelTextColor = amPmLabelTextColor ?? .secondaryLabel
        self.dotsOffColor = dotsOffColor ?? .secondarySystemBackground
        self.dotsOnColor = dotsOnColor ?? .label
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        setupClockView()
    }

    // MARK: - Public

    /// Start the clock
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

    /// Stop the clock
    public func stop() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
    }

    // MARK: - Private

    private func setupView() {
        self.addSubview(clockLabel)
        self.addSubview(amPmLabel)

        NSLayoutConstraint.activate([
            clockLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            clockLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            amPmLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            amPmLabel.topAnchor.constraint(equalTo: clockLabel.bottomAnchor)
        ])
    }

    private func setupClockView() {
        let diameter: CGFloat = min(layer.bounds.height, layer.bounds.width)
        
        let fontSize = diameter * 0.3
        font = UIFont.systemFont(ofSize: fontSize)
        amPmLabel.font = UIFont.systemFont(ofSize: fontSize * 0.5)
        
        dotDiameter = diameter * 0.03
        
        let radius: CGFloat = diameter / 2 - CGFloat(dotDiameter!) / 2

        let range = -CGFloat.pi / 2 ... CGFloat.pi * 1.5

        for idx in 0..<60 {
            let angle = range.lowerBound + CGFloat(idx) / CGFloat(60) * (range.upperBound - range.lowerBound)
            let offset = CGPoint(x: radius * cos(angle), y: radius * sin(angle))

            segmentDots[idx]!.translatesAutoresizingMaskIntoConstraints = false

            addSubview(segmentDots[idx]!)

            NSLayoutConstraint.activate([
                segmentDots[idx]!.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                segmentDots[idx]!.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y),
                segmentDots[idx]!.heightAnchor.constraint(equalToConstant: dotDiameter!),
                segmentDots[idx]!.widthAnchor.constraint(equalToConstant: dotDiameter!)
            ])
        }
    }

    private func updateClock(with calendar: Calendar) {
        let date = Date()

        let seconds = calendar.component(.second, from: date)
        
        let timeString = dateFormatter.string(from: date, with: timeFormat.rawValue)
        var amPmString = ""
        
        if timeFormat == .twelveHours {
            amPmString = dateFormatter.string(from: date, with: "a")
        }

        DispatchQueue.main.async {
            self.clockLabel.text = timeString
            self.amPmLabel.text = amPmString

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
