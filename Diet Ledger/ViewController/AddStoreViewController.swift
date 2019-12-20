//
//  AddStoreViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/19.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

class AddStoreViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func SaveStoreAction(_ sender: Any) {
        
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let store = Store(context: managedContext)
        store.name = nameTextField.text
        
        if let latitude:Double = Double(latTextField.text!)
        {
            store.latitude = latitude
        }
        

        if let longitude:Double = Double(lonTextField.text!)
        {
            store.longitude = longitude
        }
        
        if((phoneTextField.text) != ""){
            store.phone = phoneTextField.text
        }
        
        do{
            try managedContext.save()
            //rint("Save succeed.")
        }
        catch{
            print("Failed to save data.", error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
