//
//  ViewController.swift
//  LZNetwork
//
//  Created by coder-cjl on 05/22/2024.
//  Copyright (c) 2024 coder-cjl. All rights reserved.
//

import UIKit
import LZNetwork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func testLoadConfig() {
        LZEnv.default.loadConfig("xxx", loadCache: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

