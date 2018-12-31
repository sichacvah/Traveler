//
//  Card.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 21/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit
import Nuke

protocol CardDelegate {
    func cardDidTapInside(card: Card)
    func cardWillShowDetailsView(card: Card)
    func cardDidShowDetailsView(card: Card)
    func cardWillCloseDetailsView(card: Card)
    func cardDidCloseDetailsView(card: Card)
    func cardIsShowingDetails(card: Card)
    func cardDetailsIsScrolling(card: Card)
}

class Card: UIView {
    var textColor: UIColor = .black
    private var imageView = UIImageView()
    private var labelView = UILabel()
    private var textView = UILabel()

    var shadowBlur: CGFloat = 24 {
        didSet {
            self.layer.shadowRadius = shadowBlur
        }
    }
    
    var shadowOpacity: Float = 0.4 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    var shadowColor: UIColor = .gray {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    var label: String = "" {
        didSet {
            labelView.text = label
        }
    }
    
    var descriptionText: String = "" {
        didSet {
            textView.text = descriptionText
        }
    }
    
    
    
    var backgroundImageUrlString: String? {
        didSet {
            if backgroundImageUrlString != nil {
                Nuke.loadImage(
                    with: URL(string: backgroundImageUrlString!)!,
                    options: ImageLoadingOptions(
                        placeholder: UIImage(named: "Placeholder"),
                        transition: .fadeIn(duration: 0.33),
                        failureImage: UIImage(named: "Placeholder")
                    ),
                    into: self.imageView
                )
            }
        }
    }
    
    var backgroundImage: UIImage? {
        didSet {
            self.imageView.image = backgroundImage
        }
    }
    
    var cardRadius: CGFloat = 14 {
        didSet {
            self.layer.cornerRadius = cardRadius
        }
    }
    
    var contentInset: CGFloat = 6 {
        didSet {
            insets = LayoutHelper(rect: frame).X(contentInset)
        }
    }
    
   override var backgroundColor: UIColor? {
        didSet(new) {
            if let color = new { backgroundIV.backgroundColor = color }
            if backgroundColor != UIColor.clear { backgroundColor = UIColor.clear }
        }
    }
    
    private var backgroundIV = UIImageView()
    private var insets = CGFloat()
    fileprivate var tap = UITapGestureRecognizer()
    var disabledHighlightedAnimation = false
    var originalFrame = CGRect.zero
    var isPresenting = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func freezeAnimations() {
        disabledHighlightedAnimation = true
        layer.removeAllAnimations()
    }
    
    func unfreezeAnimations() {
        disabledHighlightedAnimation = false
    }

    func initialize() {
        self.addGestureRecognizer(tap)
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.addSubview(backgroundIV)
        backgroundIV.isUserInteractionEnabled = true
        
        if backgroundIV.backgroundColor == nil {
            backgroundIV.backgroundColor = UIColor.white
            super.backgroundColor = UIColor.clear
        }
    }
    
    func layout() {
        backgroundIV.addSubview(imageView)
        imageView.frame = .init(
            origin: CGPoint.zero,
            size: CGSize(
                width: backgroundIV.bounds.width,
                height: backgroundIV.bounds.height * 0.6
            )
        )
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        backgroundIV.addSubview(labelView)
        backgroundIV.addSubview(textView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: labelView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: textView)
        addConstraintsWithFormat("V:|-\(backgroundIV.bounds.height * 0.6 + 16)-[v0]", views: labelView)
        
        textView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8).isActive = true
        textView.bottomAnchor.constraint(lessThanOrEqualTo: backgroundIV.bottomAnchor, constant: -16).isActive = true
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = shadowBlur
        self.layer.cornerRadius = cardRadius

        backgroundIV.layer.cornerRadius = self.layer.cornerRadius
        backgroundIV.clipsToBounds = true
        backgroundIV.contentMode = .scaleAspectFill
        backgroundIV.frame.origin = bounds.origin
        backgroundIV.frame.size = CGSize(width: bounds.width, height: bounds.height)
        contentInset = 6
        
        labelView.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        labelView.numberOfLines = 1


        textView.font = UIFont.systemFont(ofSize: 18, weight: .light)
        textView.shadowColor = UIColor.black
        textView.shadowOffset = CGSize.zero
        textView.textColor = .lightGray
        textView.adjustsFontSizeToFitWidth = true
        textView.lineBreakMode = .byTruncatingTail
        textView.numberOfLines = 0
        textView.textAlignment = .left
        self.layout()
    }
    
    private func animate(isHighlighted: Bool) {
        if disabledHighlightedAnimation {
            return
        }
        if isHighlighted {
            UIView.animate(withDuration: 0.2, animations: { self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) })
        } else {
            UIView.animate(withDuration: 0.2, animations: { self.transform = CGAffineTransform.identity })
        }
        
    }
    
    private func shrinkAnimated() {
        animate(isHighlighted: true)
    }
    
    private func resetAnimated() {
        animate(isHighlighted: false)
    }
}

extension Card: UIGestureRecognizerDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let superview = self.superview {
            originalFrame = superview.convert(self.frame, to: nil)
        }
        shrinkAnimated()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetAnimated()
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetAnimated()
        super.touchesEnded(touches, with: event)
    }
}


extension UIImageView {
    func loadImageUsingUrlString(urlString: String) {
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }.resume()
    }
}

