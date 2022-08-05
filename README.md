# StylishClock

Just a UIView with a stylish clock in it ;)

## Usage:

Initialize ClockView:
```swift
let clock = ClockView()
```

Start the clock:
```swift
clock.start()
```

Stop the clock:
```swift
clock.stop()
```

Change parameters:
```swift
clock.dotDiameter = CGFloat(5) // Changes the diameter of the dots
clock.fontSize = CGFloat(50) // Changes the font size of the time-label

clock.textColor = UIColor.label // Changes the textcolor of the time-label
clock.dotsOffColor = UIColor.secondarySystemFill // Changes the color of the dots if in off-state
clock.dotsOnColor = UIColor.label // Changes the color of the dots if in on-state
```
