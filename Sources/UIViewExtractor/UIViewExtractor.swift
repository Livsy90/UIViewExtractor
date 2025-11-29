import SwiftUI

public extension View {
    /// Extracts the first UIKit view of the given type from the SwiftUI view hierarchy and passes it to the completion handler.
    ///
    /// This attaches an invisible background representable that searches the window's view hierarchy for the first matching `UIView` intersecting the SwiftUI view's frame, then calls `completion` on the main thread.
    ///
    /// - Parameters:
    ///   - type: The type of `UIView` to extract from the hierarchy.
    ///   - completion: A closure called with the extracted view when found.
    /// - Returns: A view that performs the extraction as a background.
    ///
    /// - Important: Extraction occurs asynchronously after layout when the view is in a window, and the completion may be called multiple times as the hierarchy updates.
    ///
    /// - Warning: This approach relies on hit-testing/intersection heuristics and may need adjustments for complex layouts.
    ///
    /// - Example:
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         ScrollView { }
    ///             .extract(UIScrollView.self) { scrollView in
    ///                 scrollView.isScrollEnabled = false
    ///             }
    ///     }
    /// }
    /// ```
    func extract<V: UIView>(
        _ type: V.Type,
        completion: @escaping (V) -> ()
    ) -> some View {
        background(ViewExtractor(completion: completion))
    }
}

private struct ViewExtractor<V: UIView>: UIViewRepresentable {
    let completion: (V) -> ()
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let view = extract(uiView) {
                completion(view)
            }
        }
    }
}

private extension ViewExtractor {
    func extract(_ uiView: UIView) -> V? {
        guard let window = uiView.window else { return nil }
        let frame = uiView.convert(uiView.bounds, to: nil)
        
        return firstMatch(in: window) {
            $0.convert($0.bounds, to: nil).intersects(frame)
        }
    }
    
    func firstMatch<T: UIView>(
        in view: UIView,
        where predicate: (T) -> Bool
    ) -> T? {
        if let match = view as? T, predicate(match) {
            return match
        }
        
        for subview in view.subviews {
            if let found = firstMatch(in: subview, where: predicate) {
                return found
            }
        }
        
        return nil
    }
}
