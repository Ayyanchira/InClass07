//
//  PhotoViewController.swift
//  InClass07
//
//  Created by Ayyanchira, Akshay Murari on 10/26/17.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Photo Delete", message: "Do you want to delete this photo?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
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
