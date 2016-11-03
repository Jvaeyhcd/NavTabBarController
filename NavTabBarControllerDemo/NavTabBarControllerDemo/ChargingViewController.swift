//
//  ChargingViewController.swift
//  NavTabBarControllerDemo
//
//  Created by polesapp-hcd on 2016/11/3.
//  Copyright © 2016年 Jvaeyhcd. All rights reserved.
//

import UIKit

class ChargingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.redColor()
        self.title = "充电"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("ChargingViewController viewWillDisappear")
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
