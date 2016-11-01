//
//  HcdNavTabBar.swift
//  NavTabBarControllerDemo
//
//  Created by polesapp-hcd on 2016/10/31.
//  Copyright © 2016年 Jvaeyhcd. All rights reserved.
//

import UIKit

protocol HcdNavTabBarDelegate {
    func hcdNavTabBar(hcdNavTabBar: HcdNavTabBar, willSelectItemAtIndex: NSInteger) -> Bool
    func hcdNavTabBar(hcdNavTabBar: HcdNavTabBar, didSelectedItemAtIndex: NSInteger)
}

class HcdNavTabBar: UIView, UIScrollViewDelegate {
    
    typealias SpecialItemHandlerBlock = (HcdNavTabItem) -> ()

    // MARK: - public property
    var items: [HcdNavTabItem]? {
        set {
            self.updateItems(items: newValue!)
        }
        get {
            return self.items
        }
    }
    var itemSelectedBgColor: UIColor? {
        set {
            self.itemSelectedBgColor = newValue
            self.itemSelectedBgImageView?.backgroundColor = self.itemSelectedBgColor
        }
        get {
            return self.itemSelectedBgColor
        }
    }
    var itemSelectedBgImage: UIImage? {
        set {
            self.itemSelectedBgImage = newValue
            self.itemSelectedBgImageView?.image = self.itemSelectedBgImage
        }
        get {
            return self.itemSelectedBgImage
        }
    }
    
    var itemSelectedBgCornerRadius: CGFloat? {
        set {
            self.itemSelectedBgCornerRadius = newValue
            self.itemSelectedBgImageView?.clipsToBounds = true
            self.itemSelectedBgImageView?.layer.cornerRadius = self.itemSelectedBgCornerRadius!
        }
        get {
            return self.itemSelectedBgCornerRadius
        }
    }
    
    
    var itemTitleColor: UIColor? {
        set {
            self.itemTitleColor = newValue
            self.items?.forEach {
                $0.titleColor = self.itemTitleColor
            }
        }
        get {
            return self.itemTitleColor
        }
    }
    var itemTitleSelectedColor: UIColor? {
        set {
            self.itemTitleSelectedColor = newValue
            self.items?.forEach {
                $0.titleSelectedColor = self.itemTitleSelectedColor
            }
        }
        get {
            return self.itemTitleSelectedColor
        }
    }
    var itemTitleFont: UIFont? {
        set {
            self.updateItemTitleFont(itemTitleFont: newValue!)
        }
        get {
            return self.itemTitleFont
        }
    }
    var itemTitleSelectedFont: UIFont? {
        set {
            self.itemTitleSelectedFont = newValue
            self.selectedItem?.titleFont = self.itemTitleSelectedFont
            self.updateItemsScaleIfNeeded()
        }
        get {
            return self.itemTitleSelectedFont
        }
    }
    
    // Badge
    var badgeBackgroundColor: UIColor? {
        
        set {
            self.badgeBackgroundColor = newValue
            self.items?.forEach{$0.badgeBackgroundColor = self.badgeBackgroundColor!}
        }
        get {
            return self.badgeBackgroundColor
        }
    }
    var badgeBackgroundImage: UIImage? {
        set {
            self.badgeBackgroundImage = newValue
            self.items?.forEach{$0.badgeBackgroundImage = self.badgeBackgroundImage!}
        }
        get {
            return self.badgeBackgroundImage
        }
    }
    var badgeTitleColor: UIColor? {
        set {
            self.badgeTitleColor = newValue
            self.items?.forEach{$0.badgeTitleColor = self.badgeTitleColor!}
        }
        get {
            return self.badgeTitleColor
        }
    }
    var badgeTitleFont: UIFont? {
        set {
            self.badgeTitleFont = newValue
            self.items?.forEach{$0.badgeTitleFont = self.badgeTitleFont!}
        }
        get {
            return self.badgeTitleFont
        }
    }
    
    var leftAndRightSpacing: CGFloat? {
        set {
            self.leftAndRightSpacing = newValue
            self.updateItemsFrame()
        }
        get {
            return self.leftAndRightSpacing
        }
    }
    var selectedItemIndex: Int {
        set {
            self.updateSelectedItemIndex(selectedItemIndex: newValue)
        }
        get {
            return self.selectedItemIndex
        }
    }
    
    var itemColorChangeFollowContentScroll: Bool?
    var itemFontChangeFollowContentScroll: Bool? {
        set {
            self.itemFontChangeFollowContentScroll = newValue
            self.updateItemsScaleIfNeeded()
        }
        get {
            return self.itemFontChangeFollowContentScroll
        }
    }
    var itemSelectedBgScrollFollowContent: Bool?
    var itemContentHorizontalCenter: Bool? {
        set {
            self.itemContentHorizontalCenter = newValue
            if self.itemContentHorizontalCenter! {
                self.setItemContentHorizontalCenterWithVerticalOffset(verticalOffset: 5, spacing: 5)
            } else {
                self.itemContentHorizontalCenterVerticalOffset = 0
                self.itemContentHorizontalCenterSpacing = 0
                self.items?.forEach{ $0.contentHorizontalCenter = false }
            }
        }
        get {
            return self.itemContentHorizontalCenter
        }
    }
    
    var delegate: HcdNavTabBarDelegate?
    
    //返回已选中的item
    var selectedItem: HcdNavTabItem? {
        set {
            self.selectedItem = newValue
        }
        get {
            if self.selectedItemIndex >= 0 && self.selectedItemIndex < (self.items?.count)! {
                return self.items![self.selectedItemIndex]
            }
            return nil
        }
    }

    // MARK: - private property
    private var scrollView: UIScrollView?
    private var specialItem: HcdNavTabItem?
    private var specialItemHandler: SpecialItemHandlerBlock!
    //选中背景
    private var itemSelectedBgImageView: UIImageView?
    //选中背景相对于YPTabItem的insets
    private var itemSelectedBgInsets: UIEdgeInsets? {
        set {
            self.itemSelectedBgInsets = newValue
            if (self.items?.count)! > 0 && self.selectedItemIndex >= 0 {
                self.updateSelectedBgFrameWithIndex(index: self.selectedItemIndex)
            }
        }
        get {
            return self.itemSelectedBgInsets
        }
    }
    //TabItem选中切换时，是否显示动画
    private var itemSelectedBgSwitchAnimated: Bool?
    //Item是否匹配title的文字宽度
    private var itemFitTextWidth: Bool?
    // 当Item匹配title的文字宽度时，左右留出的空隙，item的宽度 = 文字宽度 + spacing
    private var itemFitTextWidthSpacing: CGFloat?
    // item的宽度
    private var itemWidth: CGFloat?
    // item的内容水平居中时，image与顶部的距离
    private var itemContentHorizontalCenterVerticalOffset: CGFloat?
    // item的内容水平居中时，title与image的距离
    private var itemContentHorizontalCenterSpacing: CGFloat?
    
    // 数字样式的badge相关属性
    private var numberBadgeMarginTop: CGFloat?
    private var numberBadgeCenterMarginRight: CGFloat?
    private var numberBadgeTitleHorizonalSpace: CGFloat?
    private var numberBadgeTitleVerticalSpace: CGFloat?
    
    // 小圆点样式的badge相关属性
    private var dotBadgeMarginTop: CGFloat?
    private var dotBadgeCenterMarginRight: CGFloat?
    private var dotBadgeSideLength: CGFloat?
    
    // 分割线相关属性
    private var separatorLayers: NSMutableArray?
    private var itemSeparatorColor: UIColor?
    private var itemSeparatorWidth: CGFloat?
    private var itemSeparatorMarginTop: CGFloat?
    private var itemSeparatorMarginBottom: CGFloat?
    
    // 获取未选中字体与选中字体大小的比例
    private var itemTitleUnselectedFontScale: CGFloat {
        set {
            self.itemTitleUnselectedFontScale = newValue
        }
        get {
            if (self.itemTitleSelectedFont != nil) {
                return self.itemTitleFont!.pointSize / self.itemTitleSelectedFont!.pointSize
            }
            return CGFloat(1)
        }
    }
    
    // MARK: - public function
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.updateFrame(frame: frame)
        self.initDatas()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initDatas()
    }
    
    //根据titles创建item
    func setTitles(titles: [String]) {
        var items: [HcdNavTabItem] = [HcdNavTabItem]()
        for title in titles {
            let item = HcdNavTabItem()
            item.title = title
            items.append(item)
        }
        self.items = items
    }
    
    func setItemSelectedBgInsets(insets: UIEdgeInsets, tapSwitchAnimated: Bool) {
        self.itemSelectedBgInsets = insets
        self.itemSelectedBgSwitchAnimated = tapSwitchAnimated
    }
    
    func setScrollEnabledAndItemWidth(width: CGFloat) {
        if nil == self.scrollView {
            self.scrollView = UIScrollView.init(frame: self.bounds)
            self.scrollView?.showsVerticalScrollIndicator = false
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.addSubview(self.scrollView!)
        }
        self.itemWidth = width
        self.itemFitTextWidth = false
        self.itemFitTextWidthSpacing = 0
        
        self.updateItemsFrame()
    }
    
    func setScrollEnabledAndItemFitTextWidthWithSpacing(spacing: CGFloat) {
        if nil == self.scrollView {
            self.scrollView = UIScrollView.init(frame: self.bounds)
            self.scrollView?.showsHorizontalScrollIndicator = false
            self.scrollView?.showsVerticalScrollIndicator = false
            self.addSubview(self.scrollView!)
        }
        self.itemFitTextWidth = true
        self.itemFitTextWidthSpacing = spacing
        self.itemWidth = 0
        self.updateItemsFrame()
    }
    
    func setItemContentHorizontalCenterWithVerticalOffset(verticalOffset: CGFloat, spacing: CGFloat) {
        self.itemContentHorizontalCenter = true
        
        self.itemContentHorizontalCenterVerticalOffset = verticalOffset
        self.itemContentHorizontalCenterSpacing = spacing
        self.items?.forEach{ $0.setContentHorizontalCenterWithVerticalOffset(verticalOffset: verticalOffset, spacing: spacing) }
    }
    
    func setNumberBadgeMarginTop(marginTop: CGFloat, centerMarginRight: CGFloat, titleHorizonalSpace: CGFloat, titleVerticalSpace: CGFloat) {
        self.numberBadgeMarginTop = marginTop
        self.numberBadgeCenterMarginRight = centerMarginRight
        self.numberBadgeTitleHorizonalSpace = titleHorizonalSpace
        self.numberBadgeTitleVerticalSpace = titleVerticalSpace
        
        self.items?.forEach{
            $0.setNumberBadgeMarginTop(marginTop: marginTop, centerMarginRight: centerMarginRight, titleHorizonalSpace: titleHorizonalSpace, titleVerticalSpace: titleVerticalSpace)
        }
    }
    
    func setDotBadgeMarginTop(marginTop: CGFloat, centerMarginRight: CGFloat, sideLength: CGFloat) {
        self.dotBadgeMarginTop = marginTop
        self.dotBadgeCenterMarginRight = centerMarginRight
        self.dotBadgeSideLength = sideLength
        
        self.items?.forEach{
            $0.setDotBadgeMarginTop(marginTop: marginTop, centerMarginRight: centerMarginRight, sideLength: sideLength)
        }
    }
    
    func setItemSeparatorColor(itemSeparatorColor: UIColor, width: CGFloat, marginTop: CGFloat, marginBottom: CGFloat) {
        self.itemSeparatorColor = itemSeparatorColor
        self.itemSeparatorWidth = width
        self.itemSeparatorMarginTop = marginTop
        self.itemSeparatorMarginBottom = marginBottom
        
        self.updateSeperators()
    }
    
    func setItemSeparatorColor(itemSeparatorColor: UIColor, marginTop: CGFloat, marginBottom: CGFloat) {
        self.itemSeparatorColor = itemSeparatorColor
        self.itemSeparatorMarginTop = marginTop
        self.itemSeparatorMarginBottom = marginBottom
        
        self.updateSeperators()
    }
    
    func setSpecialItem(item: HcdNavTabItem, afterItemWithIndex: Int, tapHandler: @escaping SpecialItemHandlerBlock) {
        self.specialItem = item
        self.specialItem?.index = afterItemWithIndex
        self.specialItem?.addTarget(self, action: #selector(specialItemClicked), for: .touchUpInside)
        self.addSubview(item)
        
        self.updateItemsFrame()
        self.specialItemHandler = tapHandler
    }
    
    // MARK: - private function
    
    // 初始化数据
    private func initDatas() {
        self.backgroundColor = .white
        self.clipsToBounds = true
        
        self.selectedItemIndex = -1
        self.itemTitleColor = .white
        self.itemTitleSelectedColor = .black
        self.itemTitleFont = UIFont.systemFont(ofSize: 10)
        self.itemSelectedBgImageView = UIImageView.init(frame: .zero)
        self.itemContentHorizontalCenter = true
        self.itemFontChangeFollowContentScroll = false
        self.itemColorChangeFollowContentScroll = true
        self.itemSelectedBgScrollFollowContent = false
        
        self.badgeTitleColor = .white
        self.badgeTitleFont = UIFont.systemFont(ofSize: 13)
        self.badgeBackgroundColor = UIColor(colorLiteralRed: 252 / 255.0, green: 15 / 255.0, blue: 29 / 255.0, alpha: 1.0)
        
        self.numberBadgeMarginTop = 2
        self.numberBadgeCenterMarginRight = 30
        self.numberBadgeTitleHorizonalSpace = 8
        self.numberBadgeTitleVerticalSpace = 2
        
        self.dotBadgeMarginTop = 5
        self.dotBadgeCenterMarginRight = 25
        self.dotBadgeSideLength = 10
    }
    
    private func updateItemsFrame() {
        if self.items?.count == 0 {
            return
        }
        
        //将item从superview上删除
        self.items?.forEach{ $0.removeFromSuperview()}
        
        self.itemSelectedBgImageView?.removeFromSuperview()
        
        var index = 0
        
        if nil != self.scrollView {
            // 支持滚动
            self.scrollView?.addSubview(self.itemSelectedBgImageView!)
            var x = self.leftAndRightSpacing
            for item in self.items! {
                var width = CGFloat(0)
                // item的宽度为一个固定值
                if self.itemWidth! > CGFloat(0) {
                    width = self.itemWidth!
                }
                // item的宽度为根据字体大小和spacing进行适配
                if self.itemFitTextWidth! {
                    let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
                    let attributes = [NSFontAttributeName : self.itemTitleFont]
                    
                    let text = item.title as NSString
                    
                    let size = text.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height:  CGFloat.greatestFiniteMagnitude), options: options, attributes: attributes, context: nil).size
                    width = CGFloat(ceilf(Float(size.width))) + self.itemFitTextWidthSpacing!
                }
                item.frame = CGRect(x: x!, y: 0, width: width, height: self.frame.size.height)
                item.index = index
                x = x! + width
                self.scrollView?.addSubview(item)
                index = index + 1
            }
            self.scrollView?.contentSize = CGSize(width: max(x! + self.leftAndRightSpacing!, (self.scrollView?.frame.size.width)!), height: (self.scrollView?.frame.size.height)!)
        } else {
            // 不支持滚动
            self.addSubview(self.itemSelectedBgImageView!)
            var x = self.leftAndRightSpacing
            let allItemsWidth = self.frame.size.width - self.leftAndRightSpacing! * 2
            if nil != self.selectedItem && self.selectedItem?.frame.size.width != 0 {
                self.itemWidth = (allItemsWidth - (self.specialItem?.frame.size.width)!) / CGFloat((self.items?.count)!)
            } else {
                self.itemWidth = allItemsWidth / CGFloat((self.items?.count)!)
            }
            
            // 四舍五入，取整，防止字体模糊
            self.itemWidth = CGFloat(floorf(Float(self.itemWidth!) + 0.5))
            
            var index = 0
            
            for item in self.items! {
                if index == (self.items?.count)! - 1 {
                    self.itemWidth = self.frame.size.width - x!
                }
                item.frame = CGRect(x: x!, y: 0, width: self.itemWidth!, height: self.frame.size.height)
                item.index = index
                
                x = x! + self.itemWidth!
                self.addSubview(item)
                
                // 如果有特殊的单独item，设置其位置
                if nil != self.specialItem && self.specialItem?.index == index {
                    var width = self.specialItem?.frame.size.width
                    // 如果宽度为0，将其宽度设置为itemWidth
                    if width == 0 {
                        width = self.itemWidth
                    }
                    var height = self.specialItem?.frame.size.height
                    if height == 0 {
                        height = self.frame.size.height
                    }
                    self.specialItem?.frame = CGRect(x: x!, y: self.frame.size.height - height!, width: width!, height: height!)
                    x = x! + width!
                }
                
                index = index + 1
            }
        }
    }
    
    private func updateItemsScaleIfNeeded() {
        if nil != self.itemTitleSelectedFont && self.itemFontChangeFollowContentScroll! && self.itemTitleSelectedFont?.pointSize != self.itemTitleFont?.pointSize {
            self.items?.forEach { item in
                item.titleFont = self.itemTitleSelectedFont
                if item.isSelected {
                    item.transform = CGAffineTransform(scaleX: self.itemTitleUnselectedFontScale, y: self.itemTitleUnselectedFontScale)
                }
            }
        }
    }
    
    // 更新选中的Item
    private func updateSelectedItemIndex(selectedItemIndex: Int) {
        if (self.items?.count)! == 0 || selectedItemIndex < 0 || selectedItemIndex >= (self.items?.count)! {
            return
        }
        if self.selectedItemIndex >= 0 {
            let oldSelectedItem = self.items?[self.selectedItemIndex]
            oldSelectedItem?.isSelected = false
            if self.itemFontChangeFollowContentScroll! {
                // 如果支持字体平滑渐变切换，则设置item的scale
                oldSelectedItem?.transform = CGAffineTransform.init(scaleX: self.itemTitleUnselectedFontScale, y: self.itemTitleUnselectedFontScale)
            } else {
                // 如果不支持字体平滑渐变切换，则直接设置字体
                oldSelectedItem?.titleFont = self.itemTitleFont
            }
        }
        let newSelectedItem = self.items?[selectedItemIndex]
        newSelectedItem?.isSelected = true
        if self.itemFontChangeFollowContentScroll! {
            // 如果支持字体平滑渐变切换，则设置item的scale
            newSelectedItem?.transform = CGAffineTransform(scaleX: 1, y: 1)
        } else {
            // 如果不支持字体平滑渐变切换，则直接设置字体
            newSelectedItem?.titleFont = self.itemTitleSelectedFont
        }
        
        if self.itemSelectedBgSwitchAnimated! && self.selectedItemIndex >= 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.updateSelectedBgFrameWithIndex(index: selectedItemIndex)
            })
        } else {
            self.updateSelectedBgFrameWithIndex(index: selectedItemIndex)
        }
        
        if nil != self.delegate {
            self.delegate?.hcdNavTabBar(hcdNavTabBar: self, didSelectedItemAtIndex: selectedItemIndex)
        }
        
        self.selectedItemIndex = selectedItemIndex
        
        // 如果tabbar支持滚动，将选中的item放到tabbar的中央
        self.setSelectedItemCenter()
    }
    
    //更新选中背景的frame
    private func updateSelectedBgFrameWithIndex(index: Int) {
        if index < 0 {
            return
        }
        
        let item = self.items?[index]
        let width = (item?.frameWithOutTransform?.size.width)! - (itemSelectedBgInsets?.left)! - (self.itemSelectedBgInsets?.right)!
        let height = (item?.frameWithOutTransform?.size.height)! - (self.itemSelectedBgInsets?.top)! - (self.itemSelectedBgInsets?.bottom)!
        let x = (item?.frameWithOutTransform?.origin.x)! + (self.itemSelectedBgInsets?.left)!
        let y = (item?.frameWithOutTransform?.origin.y)! + (self.itemSelectedBgInsets?.top)!
        
        self.itemSelectedBgImageView?.frame = CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    //将选中的Item放在正中间
    private func setSelectedItemCenter() {
        if nil == self.scrollView {
            return
        }
        // 修改偏移量
        var offsetX = (self.selectedItem?.center.x)! - (self.scrollView?.frame.size.width)! * 0.5
        
        // 处理最小滚动偏移量
        if offsetX < 0 {
            offsetX = 0
        }
        
        // 处理最大滚动偏移量
        let maxOffsetX = (self.scrollView?.contentSize.width)! - (self.scrollView?.frame.size.width)!
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        self.scrollView?.setContentOffset(CGPoint(x: offsetX, y:0), animated: true)
    }
    
    // 更新Items
    private func updateItems(items: [HcdNavTabItem]) {
        self.items = items
        for item in self.items! {
            item.titleColor = self.itemTitleColor
            item.titleSelectedColor = self.itemTitleSelectedColor
            item.titleFont = self.itemTitleFont
            
            item.setContentHorizontalCenterWithVerticalOffset(verticalOffset: 5, spacing: 5)
            
            item.badgeTitleFont = self.badgeTitleFont
            item.badgeTitleColor = self.badgeTitleColor
            item.badgeBackgroundColor = self.badgeBackgroundColor!
            item.badgeBackgroundImage = self.badgeBackgroundImage
            
            item.setNumberBadgeMarginTop(marginTop: self.numberBadgeMarginTop!, centerMarginRight: self.numberBadgeCenterMarginRight!, titleHorizonalSpace: self.numberBadgeTitleHorizonalSpace!, titleVerticalSpace: self.numberBadgeTitleVerticalSpace!)
            item.setDotBadgeMarginTop(marginTop: self.dotBadgeMarginTop!, centerMarginRight: self.dotBadgeCenterMarginRight!, sideLength: self.dotBadgeSideLength!)
            
            item.addTarget(self, action: #selector(tabItemClicked), for: .touchUpInside)
        }
        
        // 更新每个item的位置
        self.updateItemsFrame()
        
        // 更新item的大小缩放
        self.updateItemsScaleIfNeeded()
    }
    
    // 更新Seperators
    private func updateSeperators() {
        if nil != self.itemSeparatorColor {
            if nil == self.separatorLayers {
                self.separatorLayers = NSMutableArray()
            }
            self.separatorLayers?.forEach{
                ($0 as! CALayer).removeFromSuperlayer()
            }
            self.separatorLayers?.removeAllObjects()
            self.items?.forEach { item in
                let layer = CALayer()
                layer.backgroundColor = self.itemSeparatorColor?.cgColor
                layer.frame = CGRect(x: item.frame.origin.x - self.itemSeparatorWidth! / 2, y: self.itemSeparatorMarginTop!, width: self.itemSeparatorWidth!, height: self.bounds.size.height - self.itemSeparatorMarginTop! - self.itemSeparatorMarginBottom!)
                self.layer.addSublayer(layer)
                
                self.separatorLayers?.add(layer)
            }
        } else {
            self.separatorLayers?.forEach{
                ($0 as! CALayer).removeFromSuperlayer()
            }
            self.separatorLayers?.removeAllObjects()
            self.separatorLayers = nil
        }
    }
    
    private func updateItemTitleFont(itemTitleFont: UIFont) {
        self.itemTitleFont = itemTitleFont
        if self.itemFontChangeFollowContentScroll! {
            // item字体支持平滑切换，更新每个item的scale
            self.updateItemsScaleIfNeeded()
        } else {
            // item字体不支持平滑切换，更新item的字体
            if (nil != self.itemTitleSelectedFont) {
                // 设置了选中字体，则只更新未选中的item
                self.items?.forEach{ item in
                    if !item.isSelected {
                        item.titleFont = itemTitleFont
                    }
                }
            } else {
                // 未设置选中字体，更新所有item
                self.items?.forEach{$0.titleFont = itemTitleFont}
            }
        }
        if self.itemFitTextWidth! {
            // 如果item的宽度是匹配文字的，更新item的位置
            self.updateItemsFrame()
        }
    }
    
    @objc private func specialItemClicked(item: HcdNavTabItem) {
        if nil != self.specialItemHandler {
            self.specialItemHandler(item)
        }
    }
    
    @objc private func tabItemClicked(item: HcdNavTabItem) {
        if self.selectedItemIndex == item.index {
            return
        }
        var will = true
        if nil != self.delegate {
            will = (self.delegate?.hcdNavTabBar(hcdNavTabBar: self, willSelectItemAtIndex: item.index))!
        }
        if will {
            self.selectedItemIndex = item.index
        }
    }
    
    private func updateFrame(frame: CGRect) {
        // 更新items的frame
        self.updateItemsFrame()
        // 更新选中背景的frame
        self.updateSelectedBgFrameWithIndex(index: self.selectedItemIndex)
        
        // 更新分割线
        self.updateSeperators()
        
        if nil != self.scrollView {
            self.scrollView?.frame = self.bounds
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        self.selectedItemIndex = Int(page)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果不是手势拖动导致的此方法被调用，不处理
        if !(scrollView.isDragging || scrollView.isDecelerating) {
            return
        }
        // 滑动越界不处理
        let offsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.size.width
        if offsetX < 0 {
            return
        }
        if offsetX > scrollView.contentSize.width - scrollViewWidth {
            return
        }
        
        let leftIndex: Int = Int(offsetX / scrollViewWidth)
        let rightIndex = leftIndex + 1
        let leftItem = self.items?[leftIndex]
        var rightItem: HcdNavTabItem? = nil
        if rightIndex < (self.items?.count)! {
            rightItem = self.items?[rightIndex]
        }
        
        // 计算右边按钮偏移量
        var rightScale: CGFloat = offsetX / scrollViewWidth
        // 只想要 0~1
        rightScale = rightScale - CGFloat(leftIndex)
        
        let leftScale = CGFloat(1) - rightScale
        if self.itemFontChangeFollowContentScroll! && self.itemTitleUnselectedFontScale != 1.0 {
            // 如果支持title大小跟随content的拖动进行变化，并且未选中字体和已选中字体的大小不一致
            
            // 计算字体大小的差值
            let diff: CGFloat = self.itemTitleUnselectedFontScale - 1
            // 根据偏移量和差值，计算缩放值
            leftItem?.transform = CGAffineTransform(scaleX: rightScale * diff + 1, y: rightScale * diff + 1)
            rightItem?.transform = CGAffineTransform(scaleX: leftScale * diff + 1, y: leftScale * diff + 1)
        }
        
        if self.itemColorChangeFollowContentScroll! {
            var normalRed = CGFloat(0), normalGreen = CGFloat(0), normalBlue = CGFloat(0)
            var selectedRed = CGFloat(0), selectedGreen = CGFloat(0), selectedBlue = CGFloat(0)
            
            self.itemTitleColor?.getRed(&normalRed, green: &normalGreen, blue: &normalBlue, alpha: nil)
            self.itemTitleSelectedColor?.getRed(&selectedRed, green: &selectedGreen, blue: &selectedBlue, alpha: nil)
            
            // 获取选中和未选中状态的颜色差值
            let redDiff = selectedRed - normalRed
            let greenDiff = selectedGreen - normalGreen
            let blueDiff = selectedBlue - normalBlue
            
            let leftRed = leftScale * redDiff + normalRed
            let leftGreen = leftScale * greenDiff + normalGreen
            let leftBlue = leftScale * blueDiff + normalBlue
            
            leftItem?.titleLabel?.textColor = UIColor(colorLiteralRed: Float(leftRed), green: Float(leftGreen), blue: Float(leftBlue), alpha: 1)
            
            let rightRed = rightScale * redDiff + normalRed
            let rightGreen = rightScale * greenDiff + normalGreen
            let rightBlue = rightScale * blueDiff + normalBlue
            
            rightItem?.titleLabel?.textColor = UIColor(colorLiteralRed: Float(rightRed), green: Float(rightGreen), blue: Float(rightBlue), alpha: 1)
            
            // 根据颜色值的差值和偏移量，设置tabItem的标题颜色
        }
        
        // 计算背景的frame
        if self.itemSelectedBgScrollFollowContent! {
            var frame = self.itemSelectedBgImageView?.frame
            let xDiff = (rightItem?.frameWithOutTransform?.origin.x)! - (leftItem?.frameWithOutTransform?.origin.x)!
            
            frame?.origin.x = rightScale * xDiff + (leftItem?.frameWithOutTransform?.origin.x)! + (self.itemSelectedBgInsets?.left)!
            
            let widthDiff = (rightItem?.frameWithOutTransform?.size.width)! - (leftItem?.frameWithOutTransform?.size.width)!
            
            if widthDiff != 0 {
                let leftSelectedBgWidth = (leftItem?.frameWithOutTransform?.size.width)! - (self.itemSelectedBgInsets?.left)! - (self.itemSelectedBgInsets?.right)!
                frame?.size.width = rightScale * widthDiff + leftSelectedBgWidth
            }
            self.itemSelectedBgImageView?.frame = frame!
        }
    }
}
