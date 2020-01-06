//
//  StoreDetailViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/19.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class StoreDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // Outlet

    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var storeFoodTableView: UITableView!
    @IBOutlet weak var lastVisitedDateLabel: UILabel!
    @IBOutlet weak var visitTimesLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var storeFoodNumberLabel: UILabel!
    
    // Varables
    var selectStore:Store?
    var foodArray = [Food]()
    var dietListArray = [DietList]()
    var totalCost = 0.0
    
    // Constants
    let dateFormat:DateFormatter = DateFormatter()
    let localtionManger = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = selectStore {
            
        }else{
            errorStoreHint()
        }
        
        storeButton.setTitle(selectStore?.name, for: .normal); 
        phoneLabel.text = selectStore?.phone
        
        storeFoodTableView.delegate = self
        storeFoodTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        syncData()
        storeFoodTableView.reloadData()
        
        localtionManger.delegate = self
        localtionManger.distanceFilter = kCLLocationAccuracyNearestTenMeters
        localtionManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        ensureGpsEnbale()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        syncData()
        storeFoodTableView.reloadData()
    }
    
    /* Fuction (Head) */

    func ensureGpsEnbale()  {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //localtionManger.requestWhenInUseAuthorization()
            distanceLabel.text = "GPS未授權"
            break
        case .authorizedWhenInUse:
            localtionManger.startUpdatingLocation()
            break
        case .denied:
            distanceLabel.text = "GPS未開啟"
            break
        default:
            break
        }
    }
    
    /* 更新GPS位置 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocaltion = locations[0] as CLLocation
        let targetLocation = CLLocation.init(latitude: selectStore!.latitude, longitude: selectStore!.longitude)
        //let eLocation = CLLocationCoordinate2D(latitude: selectStore!.latitude, longitude: selectStore!.longitude)
        //let sLocation = CLLocationCoordinate2D(latitude: currentLocaltion.coordinate.latitude, longitude: currentLocaltion.coordinate.longitude)
        let distance:CLLocationDistance = currentLocaltion.distance(from: targetLocation)
        
        if(distance < 10){
            distanceLabel.text = "小於 10 M"
        }
        else if(distance < 1000)
        {
            distanceLabel.text = String(distance.rounding(toDecimal: 2)) + " M"
        }
        else if(distance >= 1000)
        {
            distanceLabel.text = String((distance/1000).rounding(toDecimal: 2)) + " KM"
        }
    }
    
    // 同步更新Food的Data
    func syncData() {
        fetchFoodData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(foodArray.count>0){     // 資料量大於0 顯示TableView
                    storeFoodTableView.isHidden = false
                }else{                      // 反之隱藏TableView
                    storeFoodTableView.isHidden = true;
                }
                storeFoodNumberLabel.text = String(foodArray.count) + " 筆"
            }
        }
        
        fetchDietListData{ (done) in
            if(dietListArray.count>0){
                dietListArray.sort(by: >)
                dateFormat.dateFormat = "yyyy/MM/dd"
                lastVisitedDateLabel.text = dateFormat.string(from: dietListArray[0].time!)
                visitTimesLabel.text = String(dietListArray.count) + " 次"
                
                totalCost = 0.0
                
                for diet in dietListArray {
                    totalCost += diet.price
                }
                
                totalCostLabel.text = "$ " + String(totalCost)
            }
            
        }
    }
    
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
    
    
    @IBAction func storeNameAction(_ sender: Any) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "修改店家名稱",
            message: "是否修改店家名稱",
            preferredStyle: .alert)
        
        // 建立[完成]按鈕
        let okAction = UIAlertAction(
            title: "修改",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                let storeNameString = alertController.textFields?[0].text

                if(storeNameString?.count==0){
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
                
                self.selectStore?.name = storeNameString!
                self.storeButton.setTitle(self.selectStore?.name, for: .normal)

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
            textField.placeholder = "店家名稱"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            //textField.keyboardType = UIKeyboardType.phonePad
        }
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
        
    }
    
    /* IBAction Fuction (Head) */
    @IBAction func AddFoodAction(_ sender: Any) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "新增食物",
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
                food.productor = self.selectStore

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
    
    /*TableView Function (Head) */
    // 設定TableViewCell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    /*TableView Function (Tail) */
    
    // 設定TableViewCell的初始化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreFoodCell", for: indexPath) as! StoreFoodViewCell
        cell.name.text = foodArray[indexPath.row].name
        cell.type.text = foodArray[indexPath.row].type?.name
        cell.price.text = String(foodArray[indexPath.row].price)
        return cell
    }
    /*TextField Function (Head) */
    
    // 當按下右下角的return鍵時觸發
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 關閉鍵盤
        return true
    }
    
    // 設定欄位是否可以清除
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    // 表格內Cell的編輯動作 （刪除 修改
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "刪除") { (action, indexPath) in
            self.deleteFoodData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        let editAction = UITableViewRowAction(style: .destructive, title: "修改") { (action, indexPath) in
            self.deleteFoodData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return [deleteAction,editAction]
    }
    /*TextField Function (Tail) */
    
    
}

extension StoreDetailViewController{
    
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
    
    func fetchFoodData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
        request.predicate = NSPredicate.init(format: "productor == %@", selectStore!)
        do{
            foodArray = try managedContext.fetch(request) as! [Food]
            //print("Data fetch has no issue!")
            completion(true)
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            completion(false)
        }
    }
    
    func fetchDietListData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DietList")
        request.predicate = NSPredicate.init(format: "store == %@", selectStore!)
        do{
            dietListArray = try managedContext.fetch(request) as! [DietList]
            //print("Data fetch has no issue!")
            completion(true)
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
            completion(false)
        }
    }
    
    // 刪除Store內的某一筆資料
    func deleteFoodData(indexPath: IndexPath){
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(foodArray[indexPath.row])
        do{
            try managedContext.save()
            //print("Data Deleted!")
        }
        catch{
            print("Can't delete data: ", error.localizedDescription)
        }
    }
    
}



class StoreFoodViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var price: UILabel!
}

extension DietList{
    static func > (x: DietList, y: DietList) -> Bool {
        let tempX = Double(x.time!.timeIntervalSince1970)
        let tempY = Double(y.time!.timeIntervalSince1970)
        return tempX > tempY
    }
}
