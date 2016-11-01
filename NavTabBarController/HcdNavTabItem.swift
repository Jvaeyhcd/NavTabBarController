//
//  HcdNavTabItem.swift
//  NavTabBarControllerDemo
//
//  Created by polesapp-hcd on 2016/10/31.
//  Copyright © 2016年 Jvaeyhcd. All rights reserved.
//

import UIKit

enum HcdTabItemBadgeStyle {
    case Number
    case Dot
}

class HcdNavTabItem: UIButton {
    
    typealias HandlerBlock = ()->()

    //MARK: - Public property
    var index: Int = 0
    private(set) var frameWithOutTransform: CGRect?
    var size: CGSize? {
        get {
            return self.frame.size
        }
        set {
            self.size = newValue
            var rect = self.frame
            rect.size = self.size!
            self.frame = rect
        }
    }
    
    var title: String {
        set {
            self.title = newValue
            self.setTitle(title, for: .normal)
        }
        get {
            return self.title
        }
    }
    var titleColor: UIColor? {
        set {
            self.titleColor = newValue
            self.setTitleColor(self.titleColor, for: .normal)
        }
        get {
            return self.titleColor
        }
    }
    var titleSelectedColor: UIColor? {
        set {
            self.titleSelectedColor = newValue
            self.setTitleColor(self.titleSelectedColor, for: .normal)
        }
        get {
            return self.titleSelectedColor
        }
    }
    var titleFont: UIFont? {
        set {
            self.titleFont = newValue
            self.titleLabel?.font = titleFont
        }
        get {
            return self.titleFont
        }
    }
    
    var image: UIImage? {
        set {
            self.image = newValue
            self.setImage(image, for: .normal)
        }
        get {
            return self.image
        }
    }
    var selectedImage: UIImage? {
        set {
            self.selectedImage = newValue
            self.setImage(selectedImage, for: .selected)
        }
        get {
            return self.selectedImage
        }
    }
    
    var badgeNumber: Int? {
        set {
            self.badgeNumber = newValue
            self.updateBadge()
        }
        get {
            return self.badgeNumber
        }
    }
    var badgeStyle: HcdTabItemBadgeStyle? {
        set {
            self.badgeStyle = newValue
            self.updateBadge()
        }
        get {
            return self.badgeStyle
        }
    }
    var badgeBackgroundColor: UIColor {
        set {
            self.badgeBackgroundColor = newValue
            self.badgeButton?.backgroundColor = self.badgeBackgroundColor
        }
        get {
            return self.badgeBackgroundColor
        }
    }
    var badgeBackgroundImage: UIImage? {
        set {
            self.badgeBackgroundImage = newValue
            self.badgeButton?.setBackgroundImage(self.badgeBackgroundImage, for: .normal)
        }
        get {
            return self.badgeBackgroundImage
        }
    }
    var badgeTitleColor: UIColor? {
        set {
            self.badgeTitleColor = newValue
            self.badgeButton?.setTitleColor(self.badgeTitleColor, for: .normal)
        }
        
        get {
            return self.badgeTitleColor
        }
    }
    var badgeTitleFont: UIFont? {
        set {
            self.badgeTitleFont = newValue
            self.badgeButton?.titleLabel?.font = self.badgeTitleFont
        }
        
        get {
            return self.badgeTitleFont
        }
    }
    var contentHorizontalCenter: Bool? {
        set {
            self.contentHorizontalCenter = newValue
            if self.contentHorizontalCenter! {
                self.verticalOffset = CGFloat(0)
                self.spacing = CGFloat(0)
            }
            if !(self.superview?.isEqual(nil))! {
                self.layoutSubviews()
            }
        }
        get {
            return self.contentHorizontalCenter
        }
    }
    
    //MARK: - Private property
    private var badgeButton: UIButton?
    private var doubleTapView: UIView?
    private var verticalOffset: CGFloat = CGFloat(0)
    private var spacing: CGFloat = CGFloat(0)
    
    private var numberBadgeMarginTop: CGFloat = CGFloat(0)
    private var numberBadgeCenterMarginRight: CGFloat = CGFloat(0)
    private var numberBadgeTitleHorizonalSpace: CGFloat = CGFloat(0)
    private var numberBadgeTitleVerticalSpace: CGFloat = CGFloat(0)
    
    private var dotBadgeMarginTop: CGFloat = CGFloat(0)
    private var dotBadgeCenterMarginRight: CGFloat = CGFloat(0)
    private var dotBadgeSideLength: CGFloat = CGFloat(0)
    
    private var doubleTapHandler: HandlerBlock!
    
    
    // MARK: - Public function
    func setContentHorizontalCenterWithVerticalOffset(verticalOffset: CGFloat, spacing: CGFloat) {
        self.verticalOffset = verticalOffset
        self.spacing = spacing
        self.contentHorizontalCenter = true
    }
    
    func setDoubleTapHandler(handler: @escaping HandlerBlock) {
        self.doubleTapHandler = handler
        if nil == self.doubleTapView {
            self.doubleTapView = UIView(frame: self.bounds)
            self.addSubview(self.doubleTapView!)
            
            let doubleRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTapped))
            doubleRecognizer.numberOfTapsRequired = 2
            self.doubleTapView?.addGestureRecognizer(doubleRecognizer)
        }
    }
    
    func doubleTapped(recognizer: UITapGestureRecognizer) {
        if nil != self.doubleTapHandler {
            self.doubleTapHandler()
        }
    }
    
    func setNumberBadgeMarginTop(marginTop: CGFloat, centerMarginRight: CGFloat, titleHorizonalSpace: CGFloat, titleVerticalSpace: CGFloat) {
        self.numberBadgeMarginTop = marginTop
        self.numberBadgeCenterMarginRight = centerMarginRight
        self.numberBadgeTitleHorizonalSpace = titleHorizonalSpace
        self.numberBadgeTitleVerticalSpace = titleVerticalSpace
        self.updateBadge()
    }
    
    func setDotBadgeMarginTop(marginTop: CGFloat, centerMarginRight: CGFloat, sideLength: CGFloat) {
        self.dotBadgeMarginTop = marginTop
        self.dotBadgeCenterMarginRight = centerMarginRight
        self.dotBadgeSideLength = sideLength
        self.updateBadge()
    }
    
    // MARK: - Private function
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        badgeButton = UIButton(type: .custom)
        badgeButton?.isUserInteractionEnabled = false
        badgeButton?.clipsToBounds = true
        
        self.addSubview(badgeButton!)
        self.adjustsImageWhenHighlighted = true
        badgeStyle = .Number
        badgeNumber = 0
    }
    
    func updateBadge() {
        if self.badgeStyle == .Number {
            if self.badgeNumber == 0 {
                self.badgeButton?.isHidden = true
            } else {
                var badgeStr: NSString = NSNumber(value: self.badgeNumber!).stringValue as NSString
                if self.badgeNumber! > 99 {
                    badgeStr = "99+"
                }
                // 计算badgeStr的size
                let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
                let attributes = [NSFontAttributeName : self.badgeButton?.titleLabel?.font]
                let size = badgeStr.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height:  CGFloat.greatestFiniteMagnitude), options: options, attributes: attributes, context: nil).size
                
                var width = CGFloat(ceilf(Float(size.width))) + self.numberBadgeTitleHorizonalSpace
                let height = CGFloat(ceilf(Float(size.height))) + self.numberBadgeTitleVerticalSpace
                
                // 宽度取width和height的较大值，使badge为个位数时，badgeButton为圆形
                width = max(width, height)
                
                // 设置badgeButton的frame
                self.badgeButton?.frame = CGRect(x: self.bounds.size.width - width / 2 - self.numberBadgeCenterMarginRight, y: self.numberBadgeMarginTop, width: width, height: height)
                self.badgeButton?.layer.cornerRadius = (self.badgeButton?.bounds.size.height)! / 2
                self.badgeButton?.setTitle(badgeStr as String, for: .normal)
                self.badgeButton?.isHidden = false
            }
        } else if self.badgeStyle == .Dot {
            self.badgeButton?.setTitle("", for: .normal)
            self.badgeButton?.frame = CGRect(x: self.bounds.size.width - self.dotBadgeCenterMarginRight - self.dotBadgeSideLength, y: self.dotBadgeMarginTop, width: self.dotBadgeSideLength, height: self.dotBadgeSideLength)
            self.badgeButton?.layer.cornerRadius = (self.badgeButton?.bounds.size.height)! / 2
            self.badgeButton?.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (!(self.image(for: .normal)?.isEqual(nil))!) && self.contentHorizontalCenter! {
            var titleSize = titleLabel?.frame.size
            let imageSize = imageView?.frame.size
            titleSize = CGSize(width: CGFloat(ceilf(Float(titleSize!.width))), height: CGFloat(ceilf(Float(titleSize!.height))))
            let totalHeight = ((imageSize?.height)! + (titleSize?.height)! + self.spacing)
            self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - (imageSize?.height)! - self.verticalOffset), 0, 0, -(titleSize?.width)!)
            self.titleEdgeInsets = UIEdgeInsetsMake(self.verticalOffset, -(imageSize?.width)!, -(totalHeight - (titleSize?.height)!), 0)
        } else {
            self.imageEdgeInsets = .zero
            self.titleEdgeInsets = .zero
        }
    }
}
