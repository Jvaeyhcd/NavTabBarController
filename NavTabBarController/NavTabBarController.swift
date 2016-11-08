//
//  NavTabBarController.swift
//  govlan
//
//  Created by polesapp-hcd on 2016/11/2.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

import UIKit

class NavTabBarController: UIViewController, HcdTabBarDelegate{
    
    var tabBar: NavTabBar?
    private var selectedControllerIndex = -1
    private var viewControllers = [UIViewController]()
    
    private var scrollView: UIScrollView?
    private var contentViewFrame: CGRect?
    private var contentSwitchAnimated = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        // Do any additional setup after loading the view.
        
        initSubView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private
    private func initSubView() {
        
        if nil == self.tabBar {
            self.tabBar = NavTabBar.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
            self.tabBar?.backgroundColor = UIColor.whiteColor()
            self.tabBar?.showSelectedBgView(false)
            self.tabBar?.delegate = self
            
            self.view.addSubview(self.tabBar!)
        }
        
        setupFrameOfTabBarAndContentView()
        
        if nil == self.scrollView {
            self.scrollView = UIScrollView.init(frame: CGRectMake(0, 0, 0, 0))
            self.scrollView?.pagingEnabled = true
            self.scrollView!.showsHorizontalScrollIndicator = false
            self.scrollView!.alwaysBounceVertical = true
            self.scrollView!.alwaysBounceHorizontal = true
            self.scrollView!.bounces = false
            self.scrollView!.showsVerticalScrollIndicator = false
            self.scrollView!.scrollsToTop = false
            self.scrollView!.delegate = self.tabBar
            self.view.insertSubview(self.scrollView!, belowSubview: self.tabBar!)
        }
    }
    
    private func updateContentViewsFrame() {
        if nil !=  self.scrollView {
            self.scrollView?.frame = self.contentViewFrame!
            self.scrollView?.contentSize = CGSizeMake(self.contentViewFrame!.size.width * CGFloat(self.viewControllers.count), self.contentViewFrame!.size.height)
            
            var index = 0
            
            self.viewControllers.forEach{ controller in
                
                if controller.isViewLoaded() {
                    controller.view.frame = CGRectMake(CGFloat(index) * self.contentViewFrame!.size.width, 0, self.contentViewFrame!.size.width, self.contentViewFrame!.size.height)
                }
                
                index = index + 1
            }
            
            if nil != selectedController() {
                self.scrollView?.scrollRectToVisible(selectedController()!.view.frame, animated: false)
            }
        }
    }
    
    private func selectedController() -> UIViewController? {
        if self.selectedControllerIndex >= 0 {
            return self.viewControllers[self.selectedControllerIndex]
        }
        return nil
    }
    
    private func setupFrameOfTabBarAndContentView() {
        // 设置默认的tabBar的frame和contentViewFrame
        let screenSize = UIScreen.mainScreen().bounds.size
        
        let tabBarHeight = CGFloat(64)
        
        let contentViewY = tabBarHeight
        let tabBarY = CGFloat(0)
        var contentViewHeight = screenSize.height - tabBarHeight
        
        // 如果parentViewController为UINavigationController及其子类
        if nil != self.parentViewController && self.parentViewController!.isKindOfClass(UINavigationController.self) && nil != self.navigationController && !self.navigationController!.navigationBarHidden && !self.navigationController!.navigationBar.hidden {
            let navMaxY = CGRectGetMaxY(self.navigationController!.navigationBar.frame)
            if !self.navigationController!.navigationBar.translucent || self.edgesForExtendedLayout == .None || self.edgesForExtendedLayout == .Top {
                contentViewHeight = screenSize.height - tabBarHeight - navMaxY
            } else {
                
            }
        }
        self.setTabBarFrame(CGRectMake(0, tabBarY, screenSize.width, tabBarHeight), contentViewFrame: CGRectMake(0, contentViewY, screenSize.width, contentViewHeight))
    }
    
    // MARK: - Setter
    
    func setSelectedControllerIndex(selectedControllerIndex: Int) {
        
        if selectedControllerIndex < 0 || selectedControllerIndex > self.viewControllers.count - 1 {
            return
        }
        
        var oldController: UIViewController?
        if self.selectedControllerIndex >= 0 {
            oldController = self.viewControllers[self.selectedControllerIndex]
        }
        let curController = self.viewControllers[selectedControllerIndex]
        var isAppearFirstTime = true
        if nil != self.scrollView {
            oldController?.viewWillDisappear(false)
            if nil == curController.view.superview {
                // superview为空，表示为第一次加载，设置frame，并添加到scrollView
                curController.view.frame = CGRectMake(CGFloat(selectedControllerIndex) * self.scrollView!.frame.size.width, 0, self.scrollView!.frame.size.width, self.scrollView!.frame.size.height)
                self.scrollView?.addSubview(curController.view)
            } else {
                // superview不为空，表示为已经加载过了，调用viewWillAppear方法
                isAppearFirstTime = false
                curController.viewWillAppear(false)
            }
            // 切换到curController
            self.scrollView?.scrollRectToVisible(curController.view.frame, animated: self.contentSwitchAnimated)
        }
        // 当contentView为scrollView及其子类时，设置它支持点击状态栏回到顶部
        if nil != oldController && (oldController?.view.isKindOfClass(UIScrollView.self))! {
            (oldController!.view as! UIScrollView).scrollsToTop = false
        }
        if curController.view.isKindOfClass(UIScrollView.self) {
            (curController.view as! UIScrollView).scrollsToTop = true
        }
        
        self.selectedControllerIndex = selectedControllerIndex
        
        // 调用状态切换的回调方法
        
        if nil != self.scrollView {
            oldController?.viewDidDisappear(false)
            if !isAppearFirstTime {
                curController.viewDidAppear(false)
            }
        }
    }
    
    /**
     设置ViewControllers
     
     - parameter viewControllers: ViewController数组
     */
    func setViewControllers(viewControllers: [UIViewController]) {
        
        if viewControllers.count == 0 {
            return
        }
        
        self.viewControllers.forEach { controller in
            controller.removeFromParentViewController()
            controller.view.removeFromSuperview()
        }
        
        var titles = [String]()
        var index = 0
        
        self.viewControllers = viewControllers
        self.viewControllers.forEach { controller in
            self.addChildViewController(controller)
            
            var title = controller.title
            if nil == title || "" == title {
                title = "Item" + String(index + 1)
            }
            titles.append(title!)
            index = index + 1
        }
        
        self.tabBar?.setTitles(titles)
        
        self.tabBar?.setSelectedItemIndex(0)
        
        // 更新scrollView的content size
        if nil != self.scrollView {
            self.scrollView?.contentSize = CGSizeMake(self.contentViewFrame!.size.width, self.contentViewFrame!.size.height)
        }
        updateContentViewsFrame()
    }
    
    // MARK: public function
    
    /**
     设置ViewController的Content Frame
     
     - parameter contentViewFrame: viewController的ScrollView的Frame
     */
    func setContentViewFrame(contentViewFrame: CGRect) {
        self.contentViewFrame = contentViewFrame
        updateContentViewsFrame()
    }
    
    /**
     设置TabBar的Frame和ContentView的Frame
     
     - parameter tabBarFrame:      tabBar的Frame
     - parameter contentViewFrame: ContentView的Frame
     */
    func setTabBarFrame(tabBarFrame: CGRect, contentViewFrame: CGRect) {
        
        self.tabBar?.updateFrame(tabBarFrame)
        setContentViewFrame(contentViewFrame)
    }
    
    // MARK: - HcdTabBarDelegate
    func tabBar(tabBar: NavTabBar, didSelectedItemAtIndex: Int) {
        if didSelectedItemAtIndex == self.selectedControllerIndex {
            return
        }
        self.setSelectedControllerIndex(didSelectedItemAtIndex)
    }
    
    func tabBar(tabBar: NavTabBar, willSelectItemAtIndex: Int) -> Bool {
        return true
    }
    
    func leftButtonClicked() {
        
    }
    
    func rightButtonClicked() {
        
    }
}
