import Foundation

public struct RichEditorSelectionState: Decodable {
    public let canUndo: Bool
    public let canRedo: Bool
    public let isBold: Bool
    public let isItalic: Bool
    public let isUndelined: Bool
    public let isOrderedList: Bool
    public let isDotList: Bool
    public let isLink: Bool
    public let selectionLength: Int
}
