//
//  NavTabBarController.swift
//  govlan
//
//  Created by polesapp-hcd on 2016/11/2.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

import UIKit

class NavTabBarController: UIViewController {

    var tabBar: NavTabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBar = NavTabBar.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
        self.tabBar?.backgroundColor = UIColor.whiteColor()
        self.tabBar?.setTitles(["充电", "租车", "发现", "圈子", "发现", "选车"])
        self.tabBar?.showSelectedBgView(false)
        
        self.view.addSubview(self.tabBar!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
