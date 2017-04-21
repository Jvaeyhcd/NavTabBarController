//
//  SlippedSegmentItem.swift
//  govlan
//
//  Created by polesapp-hcd on 2016/11/2.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

import UIKit

class SlippedSegmentItem: UIButton {
    
    var index: Int = 0
    
    private var title: String?
    private var titleColor: UIColor?
    private var titleSelectedColor: UIColor?
    private var titleFont: UIFont?
    
    // MARK: - Set private property
    
    func setTitle(title: String) {
        self.title = title
        self.setTitle(self.title, for: .normal)
    }
    
    func setTitleColor(titleColor: UIColor) {
        self.titleColor = titleColor
        self.setTitleColor(self.titleColor, for: .normal)
    }
    
    func setTitleSelectedColor(titleSelectedColor: UIColor) {
        self.titleSelectedColor = titleSelectedColor
        self.setTitleColor(self.titleSelectedColor, for: .selected)
    }
    
    func setTitleFont(titleFont: UIFont) {
        self.titleFont = titleFont
        self.titleLabel?.font = self.titleFont
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
