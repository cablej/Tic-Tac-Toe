//
//  HomePageViewController.swift
//  Tic Tac Toe
//
//  Created by Jack Cable on 7/1/15.
//  Copyright © 2015 Jack Cable. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let dvc = segue.destinationViewController as! ViewController
        dvc.gameType = sender.tag
    }

}
