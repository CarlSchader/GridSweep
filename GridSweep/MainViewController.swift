//
//  MainViewController.swift
//  GridSweep
//
//  Created by Carl Schader on 6/3/18.
//  Copyright © 2018 bitspace. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    
    @IBOutlet weak var seedField: UITextField!
    
    @IBAction func playButtonTap(_ sender: UIButton)
    {
        performSegue(withIdentifier: "play", sender: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        seedField.endEditing(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "play"
        {
            if let gvc = segue.destination as? GameViewController
            {
                if seedField.hasText
                {
                    gvc.seed = Int(seedField.text!)
                }
                else
                {
                    seedField.text = String(arc4random())
                    gvc.seed = Int(seedField.text!)!
                }
            }
        }
    }

}
