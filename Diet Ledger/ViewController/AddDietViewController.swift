//
//  AddDietViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/21.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit

class AddDietViewController: UIViewController {

    @IBOutlet weak var dietTypeButton: UIButton!
    @IBOutlet weak var dietStoreButton: UIButton!
    @IBOutlet weak var dietDataButton: UIButton!
    @IBOutlet weak var dietPriceButton: UILabel!
    @IBOutlet weak var addFoodItemButton: UIButton!
    @IBOutlet weak var dietSaveButton: UIButton!
    @IBOutlet weak var dietFoodTableView: UITableView!
    
    var dietStore:Store?
    var dietType:DietType?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(dietStore != nil){
            dietStoreButton.titleLabel?.text = dietStore?.name
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectStore", let StorVC = segue.destination as? StoreViewController {
            StorVC.selectMode = true
        }
        if segue.identifier == "SelectDietType", let dietTypeVC = segue.destination as? DietTypeViewController {
            dietTypeVC.selectMode = true
        }
    }
    @IBAction func selectStoreAction(_ sender: Any) {
        let notificationName = Notification.Name("storeUpdated")
        NotificationCenter.default.addObserver(self, selector: #selector(storeUpdated(noti:)), name: notificationName, object: nil)
        self.performSegue(withIdentifier: "SelectStore", sender: self)
    }
    
    @IBAction func selectDietTypeAction(_ sender: Any) {
        let notificationName = Notification.Name("dietTypeUpdated")
        NotificationCenter.default.addObserver(self, selector: #selector(typeUpdated(noti:)), name: notificationName, object: nil)
        self.performSegue(withIdentifier: "SelectDietType", sender: self)
    }
    
    
    @objc func storeUpdated(noti: Notification) {
        print("Get Notification")
        let getStore = noti.object as? Store
        dietStore = getStore
        dietStoreButton.setTitle(dietStore?.name, for: .normal) 
    }
    
    @objc func typeUpdated(noti: Notification) {
        print("Get Notification")
        let getDietType = noti.object as? DietType
        dietType = getDietType
        dietTypeButton.setTitle(dietType?.name, for: .normal)
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
