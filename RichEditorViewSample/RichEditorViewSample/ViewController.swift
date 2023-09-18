//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView
import SafariServices

class ViewController: UIViewController {
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!
    var isTextColor = true
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private var selectionState: RichEditorSelectionState?
  
    private let schemeColor = UIColor.systemGreen
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
//        let options: [RichEditorDefaultOption] = [
//            .bold, .italic, .underline,
//            .unorderedList, .orderedList,
//            .indent, .outdent,
//            .textColor, .textBackgroundColor,
//            .undo, .redo,
//        ]
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.editingEnabled = false
        editorView.placeholder = "Edit here"
        let html = "<b>Jesus is God.</b> He saves by grace through faith alone. Soli Deo gloria! <a href='https://perfectGod.com'>perfectGod.com</a>"
        editorView.reloadHTML(with: html)
        
        toolbar.delegate = self
        toolbar.editor = editorView

        updateOptions()
    }
    
    private func updateOptions() {
        let undoOption = RichEditorOptionItem(sfImage("arrow.counterclockwise", isActive: selectionState?.canUndo)) { toolbar, _ in
            toolbar.editor?.undo()
        }
        let redoOption = RichEditorOptionItem(sfImage("arrow.clockwise", isActive: selectionState?.canRedo)) { toolbar, _ in
            toolbar.editor?.redo()
        }
        let boldOption = RichEditorOptionItem(sfImage("bold", isActive: selectionState?.isBold)) { toolbar, _ in
            toolbar.editor?.bold()
        }
        let italicOption = RichEditorOptionItem(sfImage("italic", isActive: selectionState?.isItalic)) { toolbar, _ in
            toolbar.editor?.italic()
        }
        let underlineOption = RichEditorOptionItem(sfImage("underline", isActive: selectionState?.isUndelined)) { toolbar, _ in
            toolbar.editor?.underline()
        }
        let linkOption = RichEditorOptionItem(sfImage("link", isActive: true)) { toolbar, _ in
            toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        }
        let dotListOption = RichEditorOptionItem(sfImage("list.bullet", isActive: selectionState?.isDotList)) { toolbar, _ in
            toolbar.editor?.unorderedList()
        }
        let numberListOption = RichEditorOptionItem(sfImage("list.number", isActive: selectionState?.isOrderedList)) { toolbar, _ in
            toolbar.editor?.orderedList()
        }
        let clearOption = RichEditorOptionItem("Clear") { (toolbar, sender) in
            toolbar.editor?.html = ""
        }
        toolbar.options = [undoOption, redoOption, boldOption, italicOption, underlineOption, linkOption, dotListOption, numberListOption, clearOption]
        toolbar.itemMargin = 16
    }
  
    private func sfImage(_ name: String, isActive: Bool?) -> UIImage {
        let isActive = isActive ?? false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: isActive ? .semibold : .regular)
        return UIImage(systemName: name, withConfiguration: config)!.withTintColor(isActive ? schemeColor : .black.withAlphaComponent(0.8), renderingMode: .alwaysOriginal)
    }
    
    @IBAction func changeEditState(_ sender: Any) {
        editorView.editingEnabled.toggle()
      
        let title: String
        if editorView.editingEnabled {
            _ = editorView.becomeFirstResponder()
            title = "Done"
        } else {
            _ = editorView.resignFirstResponder()
            title = "Edit"
        }
      
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(changeEditState(_:)))
    }

}

extension ViewController: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) { }

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }

    func richEditorTookFocus(_ editor: RichEditorView) { }
    
    func richEditorLostFocus(_ editor: RichEditorView) { }
    
    func richEditorDidLoad(_ editor: RichEditorView) { }
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool { return true }
  
    func richEditor(_ editor: RichEditorView, interactWith url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        let safari = SFSafariViewController(url: url, configuration: configuration)
        present(safari, animated: true)
    }

    func richEditor(_ editor: RichEditorView, handleCustomAction content: String) { }
}

extension ViewController: RichEditorToolbarDelegate, UIColorPickerViewControllerDelegate {
    private func presentColorPicker(title: String?, color: UIColor?) {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        picker.delegate = self
        picker.title = title
        if let color = color {
            picker.selectedColor = color
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    private func getRGBA(from color: UIColor) -> [CGFloat] {
        var R: CGFloat = 0
        var G: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 0
        
        color.getRed(&R, green: &G, blue: &B, alpha: &A)
        
        return [R, G, B, A]
    }
    
    private func isBlackOrWhite(_ color: UIColor) -> Bool {
        let RGBA = getRGBA(from: color)
        let isBlack = RGBA[0] < 0.09 && RGBA[1] < 0.09 && RGBA[2] < 0.09
        let isWhite = RGBA[0] > 0.91 && RGBA[1] > 0.91 && RGBA[2] > 0.91
        
        return isBlack || isWhite
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar, sender: AnyObject) {
        isTextColor = true
        presentColorPicker(title: "Text Color", color: .black)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar, sender: AnyObject) {
        isTextColor = false
        presentColorPicker(title: "Background Color", color: .white)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://avatars2.githubusercontent.com/u/10981?s=60", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        toolbar.editor?.canInsertLink(handler: { (canInsert) in
            if canInsert {
                self.toolbar.editor?.insertLink("https://github.com/cbess/RichEditorView", title: "GitHub Link")
            } else {
                self.toolbar.editor?.removeLink()
            }
        })
    }
    
    func richEditor(_ editor: RichEditorView, didUpdatedSelectionState state: RichEditorSelectionState) {
        selectionState = state
        updateOptions()
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        var color: UIColor? = viewController.selectedColor
        
        // don't allow black or white color changes
        if isBlackOrWhite(viewController.selectedColor) {
            color = nil
        }

        if isTextColor {
            toolbar.editor?.setTextColor(color)
        } else {
            toolbar.editor?.setTextBackgroundColor(color)
        }
    }
}
