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
        
        
//        self.tabBar?.showLeftBarButton(withImage: UIImage(named: "nav_menu_btn")!)
//        self.tabBar?.showRightBarButton(withImage: UIImage(named: "nav_menu_list")!)
        
        let vc1 = ChargingViewController()
        vc1.title = "充电"
        
        let vc2 = FindViewController()
        vc2.title = "发现"
        
        let vc3 = CarViewController()
        vc3.title = "选车"
        
        let vc4 = CircleViewController()
        vc4.title = "圈子"
        
        let vc5 = RentCarViewController()
        vc5.title = "租车"
        
        setViewControllers([vc1, vc2, vc3, vc4, vc5])
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

