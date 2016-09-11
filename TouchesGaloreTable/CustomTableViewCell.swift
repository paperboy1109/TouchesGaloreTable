//
//  CustomTableViewCell.swift
//  TouchesGaloreTable
//
//  Created by Daniel J Janiak on 9/9/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol TableViewCellDelegate {
    func toDoItemDeleted(todoItem: TableItem)
    
    /* Lifecycle methods */
    func cellDidBeginEditing(editingCell: CustomTableViewCell)
    func cellDidEndEditing(editingCell: CustomTableViewCell)
}


class CustomTableViewCell: UITableViewCell {
    
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    
    var tickLabel: UILabel
    var crossLabel: UILabel
    
    let label: StrikethroughText
    var itemCompleteLayer = CALayer()
    
    var delegate: TableViewCellDelegate?
    
    //var toDoItem: TableItem?
    // Add observer
    var toDoItem: TableItem? {
        didSet {
            label.text = toDoItem!.cellText
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        /* Label is not optional, so these properties must be initialized before calling super.init */
        label = StrikethroughText(frame: CGRect.null)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(38.0)
            label.backgroundColor = UIColor.clearColor()
            return label
        }
        
        /* Create contextual cues */
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2421}" //"\u{2620}" // "\u{2717}"
        crossLabel.textAlignment = .Left
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        /* Configure the cell labels */
        label.delegate = self
        label.contentVerticalAlignment = .Center
        
        addSubview(label)
        
        selectionStyle = .None
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.8, alpha: 0.1).CGColor as CGColorRef // UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.005, 0.99, 1.0] //[0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        addSubview(tickLabel)

        addSubview(crossLabel)
        
        /* Create a green background when the user indicates that an item in the table is "complete" */
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0,
                                                    alpha: 1.0).CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        /* Add a swipe-to-delete gesture */
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(CustomTableViewCell.handlePanGesture(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0
    let kUICuesWidth: CGFloat = 50.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
                             width: bounds.size.width - kLabelLeftMargin,
                             height: bounds.size.height)
        
        /* Add the contextual cues, initially located off-screen */
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0,
                                 width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0,
                                  width: kUICuesWidth, height: bounds.size.height)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // selectionStyle = .None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            let translation = panGestureRecognizer.translationInView(superview!)
            
            /* Ignore gestures that are mostly vertical so that the table cells still scroll well */
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    // MARK: - Helpers

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .Began {
            /* when the gesture begins, record the initial center location */
            originalCenter = center
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            
            /* Re-locate the cell in the view */
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            
            /* If the gesture is has extended for more than half the width of the cell (LEFT), cue the cell for deletion */
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            
            /* If the gesture is has extended for more than half the width of the cell (RIGHT), cue the cell for deletion */
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            
            /* Create a fade effect for the contextual cues */
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)  // width will be constant; half of the width is the distance from the center of the cell to the edge; the x coordinate changes with the left/right gesture; fabs makes sense because the alpha level will be between 0 and 1
            print("Frame width: \(frame.size.width)")
            print("Frame origin: \(frame.origin)")
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            
            /* Use color to indicate when a gesture has changed the state of the cell (delete or mark as complete) */
            tickLabel.textColor = completeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
        }
        
        if recognizer.state == .Ended {
            
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            
            /* Delete the cell */
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    delegate!.toDoItemDeleted(toDoItem!)
                }
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem!.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.hidden = false
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            } else {
                /* Return the cell to its default position */
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
        }
    }
}

extension CustomTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    /* If marked as complete, don't let the user make any edits to the text */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {        
        if toDoItem != nil {
            return !toDoItem!.completed
        }
        return false
    }
    
    /* Invoke the lifecycle protocol: cellDidBeginEditing */
    func textFieldDidBeginEditing(textField: UITextField) {
        if delegate != nil {
            delegate!.cellDidBeginEditing(self)
        }
    }
    
    /* Invoke the lifecycle protocol: cellDidEndEditing */
    func textFieldDidEndEditing(textField: UITextField) {
        if toDoItem != nil {
            toDoItem!.cellText = textField.text!
        }
        
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
    }

    
}