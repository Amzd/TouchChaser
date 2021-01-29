# 👈 TouchChaser
A touch indicator similar to the "Slide to Type" aka QuickPath swipe indicator on iOS 13+. Built with and for SwiftUI.

It's not an exact match but it's pretty close.

## Features

- **Independent:** Does not interfere with DragGestures
- **Configurable:** Choose when you want to show TouchChaser; in debug, when recording or always.
- **Simple:** Just attach it to your view and don't worry about the rest

## Example

There is an example project included but it boils down to this;

```swift 
VStack {
    Text("TouchChaser")
        .font(.title)
        .bold()
        .padding(.top, 50)
    Text("by Amzd")
        .font(.subheadline)
        .opacity(0.6)
        .padding(.top, 5)
    Spacer()
}.addTouchChaser(.always)
```

|  QuickPath                               |  TouchChaser                             |
|  --------------------------------------  |  --------------------------------------  |
|  <img src="Images/QuickPath.gif" width="100%">   | <img src="Images/TouchChaser.gif" width="100%">  |

*Gifs might not play in full speed on all browsers
