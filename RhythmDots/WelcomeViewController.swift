//
//  ViewController.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 7/9/18.
//  Copyright © 2018 Eduardo Gil. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("jalo")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func masterButtonPushed(_ sender: UIButton) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc?.master = false
        }
    }
    
    
}

