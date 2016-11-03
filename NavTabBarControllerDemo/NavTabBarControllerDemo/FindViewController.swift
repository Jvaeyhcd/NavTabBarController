//
//  FindViewController.swift
//  NavTabBarControllerDemo
//
//  Created by polesapp-hcd on 2016/11/3.
//  Copyright © 2016年 Jvaeyhcd. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.greenColor()
        self.title = "发现"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("FindViewController viewWillDisappear")
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
