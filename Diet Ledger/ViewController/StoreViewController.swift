//
//  StoreViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/18.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData


let appDelegate = UIApplication.shared.delegate as? AppDelegate

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeTableView: UITableView!
    
    var store_name = ["早安美芝城","麥當勞斗六門市","幸福牛排館"]
    var store_lat = [120.123,120.121,120.125]
    var store_lon = [23.11,23.10,23.11]
    let myEntityName = "Store"
    
    var storeArray = [Store]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storeTableView.delegate = self
        storeTableView.dataSource = self
        storeTableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()
        storeTableView.reloadData()
    }

    func syncData() {
        fetchData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                
                if(storeArray.count>0){
                    storeTableView.isHidden = false
                }else{
                    storeTableView.isHidden = true;
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreListCell", for: indexPath) as UITableViewCell
        let store = storeArray[indexPath.row]
        cell.textLabel?.text = store.name
        cell.detailTextLabel?.text = String(store.longitude) + ", " + String(store.latitude)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "刪除") { (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction]
    }
    
}

extension StoreViewController{
    
    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
        do{
            storeArray = try managedContext.fetch(request) as! [Store]
            //print("Data fetch has no issue!")
            completion(true)
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            completion(false)
        }
    }
    
    func deleteData(indexPath: IndexPath){
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(storeArray[indexPath.row])
        do{
            try managedContext.save()
            //print("Data Deleted!")
        }
        catch{
            print("Can't delete data: ", error.localizedDescription)
        }
    }
}
