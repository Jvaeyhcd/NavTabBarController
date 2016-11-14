//
//  ViewController.swift
//  NavTabBarControllerDemo
//
//  Created by polesapp-hcd on 2016/10/31.
//  Copyright © 2016年 Jvaeyhcd. All rights reserved.
//

import UIKit

class ViewController: NavTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.tabBar?.showLeftBarButton(withImage: UIImage(named: "nav_menu_btn")!)
        self.tabBar?.showRightBarButton(withImage: UIImage(named: "nav_menu_list")!)
        
        let vc1 = UIViewController()
        vc1.title = "精选"
        
        let vc2 = UIViewController()
        vc2.title = "话题"
        
        let vc3 = UIViewController()
        vc3.title = "圈子"
        
        let vc4 = UIViewController()
        vc4.title = "体育"
        
        let vc5 = UIViewController()
        vc5.title = "娱乐"
        
        let vc6 = UIViewController()
        vc6.title = "军事"
        
        setTabBarFrame(CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64), contentViewFrame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 64))
        self.tabBar?.setItemWidth(UIScreen.mainScreen().bounds.width / 5)
        self.tabBar?.setFramePadding(top: 20, left: 0, bottom: 0, right: 0)
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5, vc6])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func leftButtonClicked() {
        print("点击了左边按钮")
    }
    
    override func rightButtonClicked() {
        print("点击了右边按钮")
    }
    

}

