//
//  SlippedViewController.swift
//  NavTabBarControllerDemo
//
//  Created by Jvaeyhcd on 21/04/2017.
//  Copyright © 2017 Jvaeyhcd. All rights reserved.
//

import UIKit

class SlippedViewController: UIViewController, HcdTabBarDelegate {
    
    var tabBar: SlippedSegmentView?
    var canotScrollIndex = -1
    
    fileprivate var selectedControllerIndex = -1
    fileprivate var viewControllers = [SlippedTableViewController]()
    
    var controllersScrollView: UIScrollView?
    fileprivate var contentViewFrame: CGRect?
    fileprivate var contentSwitchAnimated = true
    
    var headView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.lightGray
        
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
            
            self.tabBar = SlippedSegmentView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            self.tabBar?.backgroundColor = UIColor.white
            self.tabBar?.showSelectedBgView(show: false)
            self.tabBar?.delegate = self
            
            self.view.addSubview(self.tabBar!)
        }
        
        setupFrameOfTabBarAndContentView()
        
        if nil == self.controllersScrollView {
            self.controllersScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
            self.controllersScrollView?.isPagingEnabled = true
            self.controllersScrollView!.showsHorizontalScrollIndicator = false
            self.controllersScrollView!.alwaysBounceVertical = true
            self.controllersScrollView!.alwaysBounceHorizontal = true
            self.controllersScrollView!.bounces = false
            self.controllersScrollView!.showsVerticalScrollIndicator = false
            self.controllersScrollView!.scrollsToTop = false
            self.controllersScrollView!.delegate = self.tabBar
            self.view.insertSubview(self.controllersScrollView!, belowSubview: self.tabBar!)
        }
        
        if nil == self.headView {
            self.headView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
            self.headView?.backgroundColor = UIColor.green
            self.view.addSubview(self.headView!)
        }
        
    }
    
    private func updateContentViewsFrame() {
        if nil !=  self.controllersScrollView {
            self.controllersScrollView?.frame = self.contentViewFrame!
            
            self.controllersScrollView?.contentSize = CGSize.init(width: self.contentViewFrame!.size.width * CGFloat(self.viewControllers.count), height: self.contentViewFrame!.size.height)
            
            var index = 0
            
            self.viewControllers.forEach{ controller in
                
                if controller.isViewLoaded {
                    
                    controller.view.frame = CGRect.init(x: CGFloat(index) * self.contentViewFrame!.size.width, y: 0, width: self.contentViewFrame!.size.width, height: self.contentViewFrame!.size.height)
                }
                
                index = index + 1
            }
            
            if nil != selectedController() {
                self.controllersScrollView?.scrollRectToVisible(selectedController()!.view.frame, animated: false)
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
        let screenSize = UIScreen.main.bounds.size
        
        let tabBarHeight = CGFloat(50)
        
        let contentViewY = tabBarHeight
        let tabBarY = CGFloat(0)
        var contentViewHeight = screenSize.height - tabBarHeight
        
        // 如果parentViewController为UINavigationController及其子类
        
        if nil != self.parent && (self.parent?.isKind(of: UINavigationController.self))! && nil != self.navigationController && !self.navigationController!.isNavigationBarHidden && !self.navigationController!.navigationBar.isHidden {
            let navMaxY = self.navigationController!.navigationBar.frame.maxY
            if !self.navigationController!.navigationBar.isTranslucent || self.edgesForExtendedLayout == .none || self.edgesForExtendedLayout == .top {
                contentViewHeight = screenSize.height - tabBarHeight - navMaxY
            } else {
                
            }
        }
        
        self.setTabBarFrame(tabBarFrame: CGRect.init(x: 0, y: tabBarY, width: screenSize.width, height: tabBarHeight), contentViewFrame: CGRect.init(x: 0, y: contentViewY, width: screenSize.width, height: contentViewHeight))
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
        if nil != self.controllersScrollView {
            oldController?.viewWillDisappear(false)
            if nil == curController.view.superview {
                // superview为空，表示为第一次加载，设置frame，并添加到scrollView
                curController.view.frame = CGRect.init(x: CGFloat(selectedControllerIndex) * self.controllersScrollView!.frame.size.width, y: 0, width: self.controllersScrollView!.frame.size.width, height: self.controllersScrollView!.frame.size.height)
                self.controllersScrollView?.addSubview(curController.view)
            } else {
                // superview不为空，表示为已经加载过了，调用viewWillAppear方法
                isAppearFirstTime = false
                curController.viewWillAppear(false)
            }
            // 切换到curController
            self.controllersScrollView?.scrollRectToVisible(curController.view.frame, animated: self.contentSwitchAnimated)
        }
        // 当contentView为scrollView及其子类时，设置它支持点击状态栏回到顶部
        if nil != oldController && (oldController?.view.isKind(of: UIScrollView.self))! {
            (oldController!.view as! UIScrollView).scrollsToTop = false
        }
        if curController.view.isKind(of: UIScrollView.self) {
            (curController.view as! UIScrollView).scrollsToTop = true
        }
        
        self.selectedControllerIndex = selectedControllerIndex
        
        // 调用状态切换的回调方法
        
        if nil != self.controllersScrollView {
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
    func setViewControllers(viewControllers: [SlippedTableViewController]) {
        
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
            controller.tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64 - 50)
            controller.tableView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            var title = controller.title
            if nil == title || "" == title {
                title = "Item" + String(index + 1)
            }
            titles.append(title!)
            index = index + 1
        }
        
        self.tabBar?.setTitles(titles: titles)
        
        self.tabBar?.setSelectedItemIndex(selectedItemIndex: 0)
        
        // 更新scrollView的content size
        if nil != self.controllersScrollView {
            self.controllersScrollView?.contentSize = CGSize.init(width: self.contentViewFrame!.size.width, height: self.contentViewFrame!.size.height)
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
        
        self.tabBar?.updateFrame(frame: tabBarFrame)
        setContentViewFrame(contentViewFrame: contentViewFrame)
    }
    
    // MARK: - HcdTabBarDelegate
    func tabBar(tabBar: SlippedSegmentView, didSelectedItemAtIndex: Int) {
        if didSelectedItemAtIndex == self.selectedControllerIndex {
            return
        }
        if didSelectedItemAtIndex == self.canotScrollIndex {
            self.controllersScrollView?.isScrollEnabled = false
        } else {
            self.controllersScrollView?.isScrollEnabled = true
        }
        
        self.setSelectedControllerIndex(selectedControllerIndex: didSelectedItemAtIndex)
    }
    
    func tabBar(tabBar: SlippedSegmentView, willSelectItemAtIndex: Int) -> Bool {
        return true
    }
    
    func leftButtonClicked() {
        
    }
    
    func rightButtonClicked() {
        
    }
}

//======================================================================
// MARK:- kvo 和 通知
//======================================================================

extension SlippedViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let tableView = object as! UITableView
        
        if keyPath != "contentOffset" {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        let tableViewoffsetY = tableView.contentOffset.y
        
        if ( tableViewoffsetY>=0 && tableViewoffsetY<=136) {
            
            self.tabBar?.frame = CGRect(x: 0, y: 200-tableViewoffsetY, width: kScreenWidth, height: 50)
            self.headView?.frame = CGRect(x: 0, y: 0-tableViewoffsetY, width: kScreenWidth, height: 200)
            self.controllersScrollView?.frame = CGRect(x: 0, y: 250-tableViewoffsetY, width: kScreenWidth, height: kScreenHeight - 64 - 50)
            
        } else if( tableViewoffsetY < 0){
            
            self.tabBar?.frame = CGRect(x: 0, y: 200, width: kScreenWidth, height: 50)
            self.headView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 200)
            self.controllersScrollView?.frame = CGRect(x: 0, y: 250, width: kScreenWidth, height: kScreenHeight - 64 - 50)
            
        } else if (tableViewoffsetY > 136){
            
            self.tabBar?.frame = CGRect(x: 0, y: 64, width: kScreenWidth, height: 50)
            self.headView?.frame = CGRect(x: 0, y: -136, width: kScreenWidth, height: 200)
            self.controllersScrollView?.frame = CGRect(x: 0, y: 64 + 50, width: kScreenWidth, height: kScreenHeight - 64 - 50)
            
        }
    }
    
}
