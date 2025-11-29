# UIViewExtractor

A lightweight SwiftUI utility to access and configure underlying UIKit views embedded in a SwiftUI hierarchy. It exposes a single API, `View.extract(_:completion:)`, that finds the first UIKit view of the specified type and passes it to your closure for configuration.

## Why use this?
SwiftUI often wraps UIKit components under the hood (for example, `ScrollView` uses `UIScrollView`). When you need to fine‑tune UIKit behavior that isn’t directly exposed by SwiftUI, `extract` gives you a safe and concise way to reach the underlying `UIView` and adjust it.

## Usage
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            // content
        }
        .extract(UIScrollView.self) { scrollView in
            scrollView.isScrollEnabled = false
        }
    }
}
