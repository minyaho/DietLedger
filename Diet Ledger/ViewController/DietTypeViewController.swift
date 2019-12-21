//
//  DietTypeViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/21.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

class DietTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {

    // Outlet
    @IBOutlet weak var dietTypeSearchBar: UISearchBar!
    @IBOutlet weak var dietTypeTableView: UITableView!
    
    // Varables
    var selectMode = false
    var dietTypeArray = [DietType]()
    var selectType:DietType?
    
    // Constants
    let myEntityName = "DietType"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dietTypeTableView 設定
        dietTypeTableView.delegate = self
        dietTypeTableView.dataSource = self
        dietTypeTableView.isHidden = true
        
        dietTypeSearchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    // ViewFunction DidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()
        dietTypeTableView.reloadData()
    }
    /* ViewFunction (Tail) */
    
    /* IBAction Fuction (Head)*/
    @IBAction func addDietTypeAction(_ sender: Any) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "新增飲食類型",
            message: "輸入以下訊息新增一筆飲食類型",
            preferredStyle: .alert)
        
        // 建立[完成]按鈕
        let okAction = UIAlertAction(
            title: "完成",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                let typeNameString = alertController.textFields?[0].text
                
                if((typeNameString?.count==0)){
                    let warn = UIAlertController(
                        title: "錯誤",
                        message: "輸入欄位有留空！\n\n請重新輸入！",
                        preferredStyle: .alert)
                    // 建立[取消]按鈕
                    let returnAction = UIAlertAction(
                        title: "返回",
                        style: .destructive,
                        handler: {
                            (action: UIAlertAction!) -> Void in
                            
                    })
                    warn.addAction(returnAction)
                    
                    // 顯示提示框
                    self.present(
                        warn,
                        animated: true,
                        completion: nil)
                    return
                }
                
                if(self.fetchDietTypeData(typeName: typeNameString!) == nil){
                guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
                let dietType = DietType(context: managedContext)
                dietType.name = typeNameString

                do{
                    try managedContext.save()
                    //rint("Save succeed.")
                }
                catch{
                    print("Failed to save data.", error.localizedDescription)
                }
                self.syncData()
                self.dietTypeTableView.reloadData()
                }
                else{
                    let warn = UIAlertController(
                        title: "錯誤",
                        message: "該飲食類型已存在！",
                        preferredStyle: .alert)
                    // 建立[取消]按鈕
                    let returnAction = UIAlertAction(
                        title: "返回",
                        style: .destructive,
                        handler: {
                            (action: UIAlertAction!) -> Void in
                            
                    })
                    warn.addAction(returnAction)
                    
                    // 顯示提示框
                    self.present(
                        warn,
                        animated: true,
                        completion: nil)
                    return
                }
        })
        alertController.addAction(okAction)
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: {
                (action: UIAlertAction!) -> Void in
                
        })
        alertController.addAction(cancelAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "類型名稱"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            //textField.isSecureTextEntry = true
        }
        

        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    /* IBAction Fuction (Tail)*/
    
    /* Fuction (Head) */
    // 同步更新Store的Data
    func syncData() {
        fetchData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(dietTypeArray.count>0){     // 資料量大於0 顯示TableView
                    dietTypeTableView.isHidden = false
                }else{                      // 反之隱藏TableView
                    dietTypeTableView.isHidden = true;
                }
            }
        }
    }


    /*TableView Function (Head) */
    // 設定TableViewCell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dietTypeArray.count
    }
    
    // 設定TableViewCell的初始化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DietTypeListCell", for: indexPath) as UITableViewCell
        let dietType = dietTypeArray[indexPath.row]
        cell.accessoryType = .checkmark
        cell.textLabel?.text = dietType.name
        //cell.detailTextLabel?.text = String(store.longitude) + ", " + String(store.latitude)
        return cell
    }
    
    // 設定可否修該Row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 單元格的編輯樣式
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // 表格內Cell的編輯動作 （刪除 修改
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "刪除") { (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        let editAction = UITableViewRowAction(style: .destructive, title: "修改") { (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return [deleteAction,editAction]
    }
    
    // 表格內Cell的短按動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)
        if(selectMode){
            print("Post Notification")
            selectType = dietTypeArray[indexPath.row]
            let notificationName = Notification.Name("dietTypeUpdated")
            NotificationCenter.default.post(name: notificationName, object: selectType, userInfo: ["dietType":self.selectType!]) //傳一個名稱叫”store”的selectStore值過去
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    /*TableView Function (Tail) */

    /*SearchBar Function (Head) */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDietType(string: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    /*SearchBar Function (Tail) */
}

extension DietTypeViewController{
    
    /* CoreData Store Entity (Head)*/
    // 抓取Store全部資料
    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
        do{
            dietTypeArray = try managedContext.fetch(request) as! [DietType]
            //print("Data fetch has no issue!")
            completion(true)
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            completion(false)
        }
    }
    
    // 刪除Store內的某一筆資料
    func deleteData(indexPath: IndexPath){
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(dietTypeArray[indexPath.row])
        do{
            try managedContext.save()
            //print("Data Deleted!")
        }
        catch{
            print("Can't delete data: ", error.localizedDescription)
        }
    }
    
    // 找尋Store內name包含string的資料
    func searchDietType(string: String){
        
        if(string != ""){
            
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
            
            request.predicate = NSPredicate.init(format: "name like[c] %@", "*"+string+"*")
            do{
                dietTypeArray = try managedContext.fetch(request) as! [DietType]
                if(dietTypeArray.count>0){
                    dietTypeTableView.isHidden = false
                }else{
                    dietTypeTableView.isHidden = true;
                }
                dietTypeTableView.reloadData()
                //print("Data fetch has no issue!")
            }
            catch{
                print("Can't fetch data: ", error.localizedDescription)
            }
        }else{
            syncData()
            dietTypeTableView.reloadData()
        }
    }
    
    func fetchDietTypeData(typeName: String) -> DietType? {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
        request.predicate = NSPredicate(format: "name == %@",typeName)
        do{
            var dietType = try managedContext.fetch(request) as! [DietType]
            //print("Data fetch has no issue!")
            if(dietType.count==0){
                return nil
            }
            else{
                let returnDietType = dietType[0]
                return returnDietType
            }
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            return nil
        }
    }
    
    /* CoreData Store Entity (Tail)*/
}
