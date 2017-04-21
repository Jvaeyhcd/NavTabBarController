//
//  SlippedDemoViewController.swift
//  NavTabBarControllerDemo
//
//  Created by Jvaeyhcd on 21/04/2017.
//  Copyright © 2017 Jvaeyhcd. All rights reserved.
//

import UIKit

class SlippedDemoViewController: SlippedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = SlippedTableViewController()
        vc1.title = "全部"
        
        let vc2 = SlippedTableViewController()
        vc2.title = "新鲜"
        
        let vc3 = SlippedTableViewController()
        vc3.title = "热门"
        
        setTabBarFrame(tabBarFrame: CGRect(x: 0, y: 200, width: kScreenWidth, height: 50), contentViewFrame: CGRect(x: 0, y: 50 + 200, width: kScreenWidth, height: kScreenHeight - 50 - 200))
        //        self.tabBar?.setItemWidth(itemWidth: UIScreen.main.bounds.width / 5)
//        self.tabBar?.setAutoResizeItemWidth(auto: true)
        self.tabBar?.setItemWidth(itemWidth: kScreenWidth / 3)
        self.tabBar?.setFramePadding(top: 0, left: 0, bottom: 0, right: 0)
        self.tabBar?.setItemHorizontalPadding(itemHorizontalPadding: 50)
        self.tabBar?.setItemSelectedBgInsets(itemSelectedBgInsets: UIEdgeInsetsMake(48, 50, 0, 50))
        self.tabBar?.showSelectedBgView(show: true)
        self.tabBar?.setItemTitleSelectedFont(itemTitleSelectedFont: UIFont.systemFont(ofSize: 14))
        self.tabBar?.setItemTitleFont(itemTitleFont: UIFont.systemFont(ofSize: 14))
        self.tabBar?.setItemTitleColor(itemTitleColor: UIColor.init(red: 0.012, green: 0.663, blue: 0.961, alpha: 1.00))
        self.tabBar?.setItemTitleSelectedColor(itemTitleSelectedColor: UIColor.init(red: 0.012, green: 0.663, blue: 0.961, alpha: 1.00))
        self.tabBar?.setItemSelectedBgImageViewColor(itemSelectedBgImageViewColor: UIColor.init(red: 0.012, green: 0.663, blue: 0.961, alpha: 1.00))
        
        setViewControllers(viewControllers: [vc1, vc2, vc3])
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
