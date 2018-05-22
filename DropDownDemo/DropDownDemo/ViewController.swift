//
//  ViewController.swift
//  DropDownDemo
//
//  Created by prakash on 22/05/18.
//  Copyright © 2018 prakash. All rights reserved.
//

import UIKit
import PNDropDown

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    var dropDown : UIDropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown = UIDropDown(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        dropDown.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY - 200)
        dropDown.placeholder = "Select your country"
        dropDown.optionsArray = ["India", "USA", "China", "France", "Germany", "Italy", "Canada"]
        dropDown.didSelect { (option, index) in
            self.label.text = "Country : \(option)"
            print("You just select: \(option) at index: \(index)")
        }
        self.view.addSubview(dropDown)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

