import AppKit
import SwiftUI
import STTextView

struct MarkdownEditorView: View {
    @Binding var text: String
    var minHeight: CGFloat = 160
    var showsLineNumbers = true
    var usesPlainStyle = false
    var font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    var contentInset = NSSize(width: 8, height: 8)

    var body: some View {
        STMarkdownTextView(
            text: $text,
            showsLineNumbers: showsLineNumbers,
            font: font,
            contentInset: contentInset
        )
            .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background {
                if usesPlainStyle {
                    Color(nsColor: .textBackgroundColor)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                }
            }
            .overlay {
                if !usesPlainStyle {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.separator.opacity(0.7))
                        .allowsHitTesting(false)
                }
            }
            .clipped()
    }
}

private struct STMarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    let showsLineNumbers: Bool
    let font: NSFont
    let contentInset: NSSize

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = STTextView.scrollableTextView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.contentInsets = NSEdgeInsets(
            top: contentInset.height,
            left: contentInset.width,
            bottom: contentInset.height,
            right: contentInset.width
        )

        let textView = scrollView.documentView as! STTextView
        textView.textDelegate = context.coordinator
        textView.font = font
        textView.textColor = .textColor
        textView.insertionPointColor = .textColor
        textView.isEditable = true
        textView.isSelectable = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = false
        textView.showsLineNumbers = showsLineNumbers
        textView.highlightSelectedLine = showsLineNumbers
        textView.gutterView?.textColor = .secondaryLabelColor
        textView.text = text

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! STTextView
        textView.isVerticallyResizable = false
        textView.isHorizontallyResizable = false
        textView.showsLineNumbers = showsLineNumbers
        textView.highlightSelectedLine = showsLineNumbers
        textView.font = font
        scrollView.contentInsets = NSEdgeInsets(
            top: contentInset.height,
            left: contentInset.width,
            bottom: contentInset.height,
            right: contentInset.width
        )

        if textView.text != text {
            context.coordinator.isUpdatingFromSwiftUI = true
            textView.text = text
            context.coordinator.isUpdatingFromSwiftUI = false
        }

        resizeDocumentView(in: scrollView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    private func resizeDocumentView(in scrollView: NSScrollView) {
        guard let textView = scrollView.documentView as? STTextView else {
            return
        }

        let visibleSize = scrollView.contentView.bounds.size
        if visibleSize.width > 0, visibleSize.height > 0 {
            textView.setFrameSize(visibleSize)
        }
    }

    @MainActor
    final class Coordinator: NSObject, @preconcurrency STTextViewDelegate {
        @Binding var text: String
        var isUpdatingFromSwiftUI = false

        init(text: Binding<String>) {
            self._text = text
        }

        func textViewDidChangeText(_ notification: Notification) {
            guard !isUpdatingFromSwiftUI, let textView = notification.object as? STTextView else {
                return
            }

            text = textView.text ?? ""
        }
    }
}
