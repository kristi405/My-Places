//
//  ReitingControl.swift
//  My Places
//
//  Created by kris on 02/06/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit

@IBDesignable class ReitingControl: UIStackView {

    // MARK: Initialization
    
    private var reitingButtons = [UIButton()]
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var buttonSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButton()
        }
    }
    
    @IBInspectable var buttonCount: Int = 5 {
        didSet {
            setupButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    @objc func buttonAction(button: UIButton) {
        
        guard let index = reitingButtons.firstIndex(of: button) else {return}
        let selectedIndex = index + 1
        
        if selectedIndex == rating {
            rating = 0
        } else {
            rating = selectedIndex
        }
    }
    
    //MARK: Setup button
    
    private func setupButton() {
        
        for button in reitingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        reitingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<buttonCount {
                        
            // create button
            let button = UIButton()
            button.setImage(filledStar, for: .selected)
            button.setImage(emptyStar, for: .normal)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // create constreints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
            
            // add button in StackView
            addArrangedSubview(button)
            
            // add button action
            button.addTarget(self, action: #selector(buttonAction(button:)), for: .touchUpInside)
            
            reitingButtons.append(button)
        }
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in reitingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
