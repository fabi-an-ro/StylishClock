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
            secondDots.forEach {
                $0.offColor = dotsOffColor
            }
        }
    }

    /// UIColor which defines the color of the second-dots when in on-state
    public var dotsOnColor: UIColor {
        didSet {
            secondDots.forEach {
                $0.onColor = dotsOnColor
            }
        }
    }
    
    /// This variable defines the time format of the clock
    public var timeFormat: TimeFormat

    private var fiveSecondDivider: Bool
    
    let dateFormatter = DateFormatter()

    var timer: Timer?

    private lazy var secondDots: [SecondDot] = {
        var dots = [SecondDot]()

        for i in 0..<60 {
            dots.append(SecondDot(onColor: dotsOnColor, offColor: dotsOffColor))
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
    
    public convenience init(timeFormat: TimeFormat = .twentyfourHours, fiveSecondDividers: Bool = false) {
        self.init(timeFormat: timeFormat,
                  fiveSecondDividers: fiveSecondDividers,
                  timeLabelTextColor: .label,
                  amPmLabelTextColor: .secondaryLabel,
                  dotsOffColor: .secondarySystemBackground,
                  dotsOnColor: .label)
    }
    
    public init(timeFormat: TimeFormat, fiveSecondDividers: Bool, timeLabelTextColor: UIColor?, amPmLabelTextColor: UIColor?, dotsOffColor: UIColor?, dotsOnColor: UIColor?) {
        self.timeFormat = timeFormat
        self.fiveSecondDivider = fiveSecondDividers
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

        for (idx, dot) in secondDots.enumerated() {
            let angle = range.lowerBound + CGFloat(idx) / CGFloat(60) * (range.upperBound - range.lowerBound)
            let offset = CGPoint(x: radius * cos(angle), y: radius * sin(angle))

            dot.translatesAutoresizingMaskIntoConstraints = false

            addSubview(dot)

            NSLayoutConstraint.activate([
                dot.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y)
            ])

            setSize(of: dot, with: idx)
        }
    }

    private func setSize(of dot: SecondDot, with index: Int) {
        if fiveSecondDivider {
            switch index {
            case 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55:
                NSLayoutConstraint.activate([
                    dot.heightAnchor.constraint(equalToConstant: dotDiameter! * 1.4),
                    dot.widthAnchor.constraint(equalToConstant: dotDiameter! * 1.4),
                ])
            default:
                NSLayoutConstraint.activate([
                    dot.heightAnchor.constraint(equalToConstant: dotDiameter!),
                    dot.widthAnchor.constraint(equalToConstant: dotDiameter!)
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                dot.heightAnchor.constraint(equalToConstant: dotDiameter!),
                dot.widthAnchor.constraint(equalToConstant: dotDiameter!)
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

            for (idx, dot) in self.secondDots.enumerated() {
                if idx <= seconds {
                    dot.state = .on
                } else {
                    dot.state = .off
                }
            }
        }
    }
}

#endif
