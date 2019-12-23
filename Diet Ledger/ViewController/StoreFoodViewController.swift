//
//  StoreFoodViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/23.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

class StoreFoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    // Outlet
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var storeFoodTableView: UITableView!
    
    
    // Varables
    var selectMode = false
    var storeFoodArray = [Food]()
    var selectStoreFood:Food?
    var whichStore:Store?
    
    // Constants
    let myEntityName = "Food"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeFoodTableView.delegate = self
        storeFoodTableView.dataSource = self
        storeFoodTableView.isHidden = true
            
        foodSearchBar.delegate = self

    }
    // ViewFunction DidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if whichStore != nil{
            syncData()
            storeFoodTableView.reloadData()
        }else{
            errorStoreHint()
        }
    }
    /* ViewFunction (Tail) */
    
    //  建立錯誤訊息提示框
    func errorStoreHint() {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "錯誤",
            message: "無法獲得商家資訊",
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let returnAction = UIAlertAction(
            title: "返回",
            style: .destructive,
            handler: {
                (action: UIAlertAction!) -> Void in
                // 返回上一頁
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(returnAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    /* IBAction Fuction (Head)*/
    @IBAction func addStoreFoodAction(_ sender: Any) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "新增店家食物",
            message: "輸入以下訊息新增該店家的食物",
            preferredStyle: .alert)
        
        // 建立[完成]按鈕
        let okAction = UIAlertAction(
            title: "完成",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                let foodNameString = alertController.textFields?[0].text
                let foodTypeString = alertController.textFields?[1].text
                let foodPriceString = alertController.textFields?[2].text
                
                if((foodNameString?.count==0) || (foodTypeString?.count==0) || (foodPriceString?.count==0)){
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
                
                var foodType:FoodType?
                if let temp = self.fetchFoodTypeData(typeName: foodTypeString!){
                    foodType = temp
                }else{
                    guard let typeManagedContext  = appDelegate?.persistentContainer.viewContext else { return }
                    let type = FoodType(context: typeManagedContext)
                    type.name = foodTypeString
                    do{
                        try typeManagedContext.save()
                        //rint("Save succeed.")
                    }
                    catch{
                        print("Failed to save data.", error.localizedDescription)
                    }
                    
                    if let temp2 = self.fetchFoodTypeData(typeName: foodTypeString!){
                        foodType = temp2
                    }
                }
                
                guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
                let food = Food(context: managedContext)
                food.name = foodNameString
                food.type = foodType
                if let tempString = alertController.textFields?[2].text
                {
                    if let price:Double = Double(tempString)
                    {
                        food.price = price
                    }
                    else{ food.price = 0.0 }
                }else{ food.price = 0.0 }
                food.productor = self.whichStore
                
                do{
                    try managedContext.save()
                    //rint("Save succeed.")
                }
                catch{
                    print("Failed to save data.", error.localizedDescription)
                }
                self.syncData()
                self.storeFoodTableView.reloadData()
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
            textField.placeholder = "品名"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            //textField.keyboardType = UIKeyboardType.phonePad
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "類型"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            //textField.isSecureTextEntry = true
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "價格"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            textField.keyboardType = UIKeyboardType.numberPad
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
                if(storeFoodArray.count>0){     // 資料量大於0 顯示TableView
                    storeFoodTableView.isHidden = false
                }else{                      // 反之隱藏TableView
                    storeFoodTableView.isHidden = true;
                }
            }
        }
    }
    
    
    /*TableView Function (Head) */
    // 設定TableViewCell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeFoodArray.count
    }
    
    // 設定TableViewCell的初始化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreFoodListCell", for: indexPath) as UITableViewCell
        let storeFood = storeFoodArray[indexPath.row]
        //cell.accessoryType = .checkmark
        cell.textLabel?.text = storeFood.name
        cell.detailTextLabel?.text = String(storeFood.price)
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
            selectStoreFood = storeFoodArray[indexPath.row]
            self.navigationController?.popViewController(animated: true)
            let notificationName = Notification.Name("dietFoodUpdated")
            NotificationCenter.default.post(name: notificationName, object: selectStoreFood, userInfo: ["dietType":self.selectStoreFood!]) //傳一個名稱叫”store”的selectStore值過去
        }
    }
    /*TableView Function (Tail) */
    
    /*SearchBar Function (Head) */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStoreFood(string: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    /*SearchBar Function (Tail) */
}

extension StoreFoodViewController{
    
    /* CoreData Store Entity (Head)*/
    // 抓取Store全部資料
    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
        request.predicate = NSPredicate(format: "productor == %@", whichStore!)
        do{
            storeFoodArray = try managedContext.fetch(request) as! [Food]
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
        managedContext.delete(storeFoodArray[indexPath.row])
        do{
            try managedContext.save()
            //print("Data Deleted!")
        }
        catch{
            print("Can't delete data: ", error.localizedDescription)
        }
    }
    
    // 找尋Store內name包含string的資料
    func searchStoreFood(string: String){
        
        if(string != ""){
            
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
            
            request.predicate = NSPredicate.init(format: "name like[c] %@ AND productor == %@", "*"+string+"*", whichStore!)
            do{
                storeFoodArray = try managedContext.fetch(request) as! [Food]
                if(storeFoodArray.count>0){
                    storeFoodTableView.isHidden = false
                }else{
                    storeFoodTableView.isHidden = true;
                }
                storeFoodTableView.reloadData()
                //print("Data fetch has no issue!")
            }
            catch{
                print("Can't fetch data: ", error.localizedDescription)
            }
        }else{
            syncData()
            storeFoodTableView.reloadData()
        }
    }
    
    func fetchFoodTypeData(typeName: String) -> FoodType? {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodType")
        request.predicate = NSPredicate(format: "name == %@",typeName)
        do{
            var foodType = try managedContext.fetch(request) as! [FoodType]
            //print("Data fetch has no issue!")
            if(foodType.count==0){
                return nil
            }
            else{
                let returnFoodType = foodType[0]
                return returnFoodType
            }
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            return nil
        }
    }
}
