//
//  NavTabBar.swift
//  govlan
//
//  Created by polesapp-hcd on 2016/11/2.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

import UIKit

protocol HcdTabBarDelegate {
    func tabBar(tabBar: NavTabBar, willSelectItemAtIndex: Int) -> Bool
    func tabBar(tabBar: NavTabBar, didSelectedItemAtIndex: Int)
    func leftButtonClicked()
    func rightButtonClicked()
}

extension HcdTabBarDelegate {
    
    // 定义可选协议
    func leftButtonClicked() {
        
    }
    
    func rightButtonClicked() {
        
    }
}

class NavTabBar: UIView, UIScrollViewDelegate {
    
    var delegate: HcdTabBarDelegate?
    
    var leftAndRightSpacing = CGFloat(0)
    var itemSelectedBgInsets = UIEdgeInsetsMake(40, 15, 0, 15)
    
    // Item的宽度，默认值70
    private var itemWidth = CGFloat(70)
    // 选中的Item的index
    private var selectedItemIndex = -1
    private var scrollView: UIScrollView?
    private var items: [NavTabBarItem] = [NavTabBarItem]()
    private var itemSelectedBgImageView: UIImageView?
    // item的选中字体大小，默认20
    private var itemTitleSelectedFont = UIFont.systemFontOfSize(20)
    // item的没有选中字体大小，默认16
    private var itemTitleFont = UIFont.systemFontOfSize(16)
    
    // 拖动内容视图时，item的颜色是否根据拖动位置显示渐变效果，默认为false
    private var itemColorChangeFollowContentScroll = true
    // 拖动内容视图时，item的字体是否根据拖动位置显示渐变效果，默认为false
    private var itemFontChangeFollowContentScroll = true
    // TabItem的选中背景是否随contentView滑动而移动
    private var itemSelectedBgScrollFollowContent = true
    
    // TabItem选中切换时，是否显示动画
    private var itemSelectedBgSwitchAnimated = true
    
    // Item未选中的字体颜色
    private var itemTitleColor: UIColor = UIColor.lightGrayColor()
    // Item选中的字体颜色
    private var itemTitleSelectedColor: UIColor = UIColor.init(red: 0.000, green: 0.655, blue: 0.937, alpha: 1.00)//[UIColor colorWithRed:0.000 green:0.655 blue:0.937 alpha:1.00]
    
    // 左右两边的图片按钮
    private var leftButton, rightButton: UIButton?
    // 左右按钮是否显示
    private var showLeftButton = false, showRightButton = false
    private var buttonWidth = CGFloat(50)
    private var paddingTop = CGFloat(0), paddingLeft = CGFloat(0), paddingBottom = CGFloat(0), paddingRight = CGFloat(0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
        initDatas()
    }
    
    // MARK: - Setter
    
    /**
     设置切换是否动态改变Item字体颜色
     
     - parameter itemColorChangeFollowContentScroll: Bool true or false
     */
    func setItemColorChangeFollowContentScroll(itemColorChangeFollowContentScroll: Bool) {
        self.itemColorChangeFollowContentScroll = itemColorChangeFollowContentScroll
    }
    
    /**
     设置切换是否动态改变Item字体大小
     
     - parameter itemFontChangeFollowContentScroll: Bool true or false
     */
    func setItemFontChangeFollowContentScroll(itemFontChangeFollowContentScroll: Bool) {
        self.itemFontChangeFollowContentScroll = itemFontChangeFollowContentScroll
    }
    
    func setItemTitleFont(itemTitleFont: UIFont) {
        self.itemTitleFont = itemTitleFont
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
    }
    
    func setItemTitleSelectedFont(itemTitleSelectedFont: UIFont) {
        self.itemTitleSelectedFont = itemTitleSelectedFont
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
    }
    
    func setItemTitleColor(itemTitleColor: UIColor) {
        self.itemTitleColor = itemTitleColor
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
    }
    
    func setItemTitleSelectedColor(itemTitleSelectedColor: UIColor) {
        self.itemTitleSelectedColor = itemTitleSelectedColor
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
    }
    
    func setItemWidth(itemWidth: CGFloat) {
        self.itemWidth = itemWidth
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
    }
    
    func setFramePadding(top top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.paddingTop = top
        self.paddingLeft = left
        self.paddingBottom = bottom
        self.paddingRight = right
        updateScrollViewFrame()
    }
    
    /**
     设置选中Item下标
     
     - parameter selectedItemIndex: 选中Item的index
     */
    func setSelectedItemIndex(selectedItemIndex: Int) {
        if self.items.count == 0 || selectedItemIndex < 0 || selectedItemIndex >= self.items.count {
            return
        }
        
        if self.selectedItemIndex >= 0 {
            let oldSelectedItem = self.items[self.selectedItemIndex]
            oldSelectedItem.selected = false
            if self.itemFontChangeFollowContentScroll {
                // 如果支持字体平滑渐变切换，则设置item的scale
                let itemTitleUnselectedFontScale = self.itemTitleFont.pointSize / self.itemTitleSelectedFont.pointSize
                oldSelectedItem.transform = CGAffineTransformMakeScale(itemTitleUnselectedFontScale, itemTitleUnselectedFontScale)
            } else {
                // 如果支持字体平滑渐变切换，则直接设置字体
                oldSelectedItem.setTitleFont(self.itemTitleFont)
            }
        }
        
        let newSelectedItem = self.items[selectedItemIndex]
        newSelectedItem.selected = true
        if self.itemFontChangeFollowContentScroll {
            // 如果支持字体平滑渐变切换，则设置item的scale
            newSelectedItem.transform = CGAffineTransformMakeScale(1, 1)
        } else {
            // 如果支持字体平滑渐变切换，则直接设置字体
            newSelectedItem.setTitleFont(self.itemTitleSelectedFont)
        }
        
        if self.itemSelectedBgSwitchAnimated && self.selectedItemIndex >= 0 {
            UIView.animateWithDuration(0.25, animations: {
                self.updateSelectedBgFrameWithIndex(selectedItemIndex)
            })
        } else {
            self.updateSelectedBgFrameWithIndex(selectedItemIndex)
        }
        
        // didSelectedItemAtIndex
        if nil != self.delegate {
            self.delegate?.tabBar(self, didSelectedItemAtIndex: selectedItemIndex)
        }
        
        self.selectedItemIndex = selectedItemIndex
        setSelectedItemCenter()
    }
    
    /**
     设置Items
     
     - parameter items: Items数组
     */
    func setItems(items: [NavTabBarItem]) {
        self.items.forEach{ $0.removeFromSuperview() }
        
        self.items = items
        
        updateItemsFrame()
        setSelectedItemIndex(self.selectedItemIndex)
        updateItemsScaleIfNeeded()
        
    }
    
    /**
     Item点击事件
     
     - parameter item: 被点击的Item
     */
    @objc private func tabItemClicked(item: NavTabBarItem) {
        if self.selectedItemIndex == item.index {
            return
        }
        setSelectedItemIndex(item.index)
    }
    
    /**
     左边按钮点击事件
     
     - parameter button: 点击的Button
     */
    @objc private func leftButtonClicked(button: UIButton) {
        if nil != self.delegate {
            self.delegate?.leftButtonClicked()
        }
    }
    
    /**
     右边按钮点击事件
     
     - parameter button: 点击的Button
     */
    @objc private func rightButtonClicked(button: UIButton) {
        if nil != self.delegate {
            self.delegate?.rightButtonClicked()
        }
    }
    
    // MARK: - public fucntion
    
    func updateFrame(frame: CGRect) {
        self.frame = frame
        updateScrollViewFrame()
    }
    
    /**
     设置是否显示选中Item的背景图片
     
     - parameter show: ture or false
     */
    func showSelectedBgView(show: Bool) {
        self.itemSelectedBgScrollFollowContent = show
        self.itemSelectedBgImageView?.hidden = !show
    }
    
    /**
     设置Items的titles
     
     - parameter titles: title数组
     */
    func setTitles(titles: [String]) {
        var items = [NavTabBarItem]()
        for title in titles {
            let item = NavTabBarItem()
            item.setTitle(title, forState: .Normal)
            items.append(item)
        }
        
        setItems(items)
    }
    
    /**
     显示左边按钮
     
     - parameter image: 按钮图片
     */
    func showLeftBarButton(withImage image: UIImage) {
        self.showLeftButton = true
        if nil == self.leftButton {
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            self.leftButton = UIButton.init(frame: CGRectMake(0, statusBarHeight, buttonWidth, self.bounds.height - statusBarHeight))
            self.leftButton?.backgroundColor = UIColor.clearColor()
            self.leftButton?.addTarget(self, action: #selector(leftButtonClicked(_:)), forControlEvents: .TouchUpInside)
            self.addSubview(self.leftButton!)
        }
        
        self.leftButton?.setImage(image, forState: .Normal)
        self.updateScrollViewFrame()
    }
    
    /**
     显示右边按钮
     
     - parameter image: 按钮图片
     */
    func showRightBarButton(withImage image: UIImage) {
        self.showRightButton = true
        if nil == self.rightButton {
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            self.rightButton = UIButton.init(frame: CGRectMake(self.bounds.width - buttonWidth, statusBarHeight, buttonWidth, self.bounds.height - statusBarHeight))
            self.rightButton?.backgroundColor = UIColor.clearColor()
            self.rightButton?.addTarget(self, action: #selector(rightButtonClicked(_:)), forControlEvents: .TouchUpInside)
            self.addSubview(self.rightButton!)
        }
        
        self.rightButton?.setImage(image, forState: .Normal)
        self.updateScrollViewFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private function
    
    /**
     初始化一些界面组件
     
     - returns:
     */
    private func initSubViews() {
        
        if nil == self.scrollView {
            
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            
            self.scrollView = UIScrollView.init(frame: CGRectMake(0, statusBarHeight, self.bounds.width, self.bounds.height - statusBarHeight))
            self.scrollView?.showsVerticalScrollIndicator = false
            self.scrollView?.showsHorizontalScrollIndicator = false
            
            self.addSubview(self.scrollView!)
        }
        
        if nil == self.itemSelectedBgImageView {
            self.itemSelectedBgImageView = UIImageView.init(frame: .zero)
            self.itemSelectedBgImageView?.backgroundColor = UIColor.init(red: 0.000, green: 0.655, blue: 0.937, alpha: 1.00)
        }
    }
    
    private func initDatas() {
        
    }
    
    /**
     更新items的Frame
     */
    private func updateItemsFrame() {
        if self.items.count == 0 {
            return
        }
        
        // 将item从superview上删除
        self.items.forEach{ $0.removeFromSuperview() }
        self.itemSelectedBgImageView!.removeFromSuperview()
        
        if nil != self.scrollView {
            self.scrollView?.addSubview(self.itemSelectedBgImageView!)
            var x = self.leftAndRightSpacing
            var index = 0
            for item in self.items {
                
                var width = CGFloat(0)
                if itemWidth > 0 {
                    width = itemWidth
                }
                
                item.frame = CGRectMake(x, 0, width, self.scrollView!.bounds.height)
                item.setTitleColor(self.itemTitleColor)
                item.setTitleSelectedColor(self.itemTitleSelectedColor)
                item.setTitleFont(self.itemTitleFont)
                item.addTarget(self, action: #selector(tabItemClicked(_:)), forControlEvents: .TouchUpInside)
                item.index = index
                
                x = x + width
                index = index + 1
                self.scrollView?.addSubview(item)
            }
            
            self.scrollView?.contentSize = CGSizeMake(MAX(x + self.leftAndRightSpacing, value2: self.scrollView!.frame.size.width), self.scrollView!.frame.size.height)
        }
    }
    
    /**
     更新ScrollView的Frame
     */
    private func updateScrollViewFrame() {
        var x = self.paddingLeft
        let y = self.paddingTop
        
        var width = self.frame.size.width - self.paddingLeft - self.paddingRight
        let height = self.frame.size.height - self.paddingTop - self.paddingBottom
        
        if self.showLeftButton {
            x = self.buttonWidth
            width = width - self.buttonWidth
        }
        
        if self.showRightButton {
            width = width - self.buttonWidth
        }
        
        self.scrollView?.frame = CGRectMake(x, y, width, height)
        
        self.updateItemsFrame()
    }
    
    /**
     更新选中的Item的背景
     
     - parameter index: 选中的Item的index
     */
    private func updateSelectedBgFrameWithIndex(index: Int) {
        if index < 0 || index > self.items.count {
            return
        }
        let item = self.items[index]
        let width = item.frame.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right
        let height = item.frame.size.height - self.itemSelectedBgInsets.top - self.itemSelectedBgInsets.bottom
        self.itemSelectedBgImageView!.frame = CGRectMake(item.frame.origin.x + self.itemSelectedBgInsets.left,
                                                         item.frame.origin.y + self.itemSelectedBgInsets.top,
                                                         width,
                                                         height)
    }
    
    /**
     更新item的大小缩放
     */
    private func updateItemsScaleIfNeeded() {
        if self.itemFontChangeFollowContentScroll {
            self.items.forEach{
                $0.setTitleFont(self.itemTitleSelectedFont)
                if !$0.selected {
                    
                    let itemTitleUnselectedFontScale = self.itemTitleFont.pointSize / self.itemTitleSelectedFont.pointSize
                    
                    $0.transform = CGAffineTransformMakeScale(itemTitleUnselectedFontScale, itemTitleUnselectedFontScale)
                }
            }
            
        }
    }
    
    /**
     获取选中的Item
     
     - returns: 选中的Item
     */
    private func selectedItem() -> NavTabBarItem? {
        
        if self.selectedItemIndex >= 0 && self.selectedItemIndex < self.items.count {
            return self.items[self.selectedItemIndex]
        }
        
        return nil
    }
    
    /**
     将选中的Item更新到中间位置
     */
    private func setSelectedItemCenter() {
        
        let selectedItem = self.selectedItem()
        
        if nil == selectedItem {
            return
        }
        
        // 修改偏移量
        var offsetX = selectedItem!.center.x - self.scrollView!.frame.size.width * 0.5
        
        // 处理最小滚动偏移量
        if offsetX < 0 {
            offsetX = 0
        }
        
        // 处理最大滚动偏移量
        let maxOffsetX = self.scrollView!.contentSize.width - self.scrollView!.frame.size.width
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        self.scrollView?.setContentOffset(CGPointMake(offsetX, 0), animated: true)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    func MAX(value1: CGFloat, value2: CGFloat) -> CGFloat {
        if value1 > value2 {
            return value1
        }
        return value2
    }
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 这里的Delegate是给NavTabController调用的
        if scrollView.isEqual(self.scrollView) {
            return
        }
        
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.size.width)
        setSelectedItemIndex(page)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // 这里的Delegate是给NavTabController调用的
        if scrollView.isEqual(self.scrollView) {
            return
        }
        
        // 如果不是手势拖动导致的此方法被调用，不处理
        if !(scrollView.dragging || scrollView.decelerating) {
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
        
        let leftIndex = Int(offsetX) / Int(scrollViewWidth)
        let rightIndex = leftIndex + 1
        
        if leftIndex >= self.items.count || rightIndex >= self.items.count {
            return
        }
        let leftItem = self.items[leftIndex]
        let rightItem = self.items[rightIndex]
        // 计算右边按钮偏移量
        var rightScale = offsetX / scrollViewWidth
        // 只想要 0~1
        rightScale = rightScale - CGFloat(leftIndex)
        let leftScale = 1 - rightScale
        if self.itemFontChangeFollowContentScroll {
            // 如果支持title大小跟随content的拖动进行变化，并且未选中字体和已选中字体的大小不一致
            
            let itemTitleUnselectedFontScale = self.itemTitleFont.pointSize / self.itemTitleSelectedFont.pointSize
            // 计算字体大小的差值
            let diff = itemTitleUnselectedFontScale - 1
            // 根据偏移量和差值，计算缩放值
            leftItem.transform = CGAffineTransformMakeScale(rightScale * diff + 1, rightScale * diff + 1)
            rightItem.transform = CGAffineTransformMakeScale(leftScale * diff + 1, leftScale * diff + 1)
        }
        
        // 计算颜色的渐变
        if self.itemColorChangeFollowContentScroll {
            var normalRed = CGFloat(0), normalGreen = CGFloat(0), normalBlue = CGFloat(0)
            var selectedRed = CGFloat(0), selectedGreen = CGFloat(0), selectedBlue = CGFloat(0)
            
            self.itemTitleColor.getRed(&normalRed, green: &normalGreen, blue: &normalBlue, alpha: nil)
            self.itemTitleSelectedColor.getRed(&selectedRed, green: &selectedGreen, blue: &selectedBlue, alpha: nil)
            
            // 获取选中和未选中状态的颜色差值
            let redDiff = selectedRed - normalRed
            let greenDiff = selectedGreen - normalGreen
            let blueDiff = selectedBlue - normalBlue
            // 根据颜色值的差值和偏移量，设置tabItem的标题颜色
            leftItem.titleLabel!.textColor = UIColor.init(red: leftScale * redDiff + normalRed, green: leftScale * greenDiff + normalGreen, blue: leftScale * blueDiff + normalBlue, alpha: 1)
            rightItem.titleLabel!.textColor = UIColor.init(red: rightScale * redDiff + normalRed, green: rightScale * greenDiff + normalGreen, blue: rightScale * blueDiff + normalBlue, alpha: 1)
        }
        
        // 计算背景的frame
        if self.itemSelectedBgScrollFollowContent {
            var frame = self.itemSelectedBgImageView!.frame
            
            let xDiff = rightItem.frame.origin.x - leftItem.frame.origin.x
            frame.origin.x = rightScale * xDiff + leftItem.frame.origin.x + self.itemSelectedBgInsets.left
            
            let widthDiff = rightItem.frame.size.width - leftItem.frame.size.width
            if widthDiff != 0 {
                let leftSelectedBgWidth = leftItem.frame.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right
                frame.size.width = rightScale * widthDiff + leftSelectedBgWidth
            }
            self.itemSelectedBgImageView!.frame = frame
        }
    }
    
}
