//
//  AddDietViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/21.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

class DietViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dietTypeButton: UIButton!
    @IBOutlet weak var dietStoreButton: UIButton!
    @IBOutlet weak var dietPriceLabel: UILabel!
    @IBOutlet weak var addFoodItemButton: UIButton!
    @IBOutlet weak var dietSaveButton: UIButton!
    @IBOutlet weak var dietFoodTableView: UITableView!
    @IBOutlet weak var setTimeTextField: UITextField!
    @IBOutlet weak var totalCostLabel: UIView!
    
    let dietTimePicker = UIDatePicker()
    
    var dietStore:Store?
    var dietType:DietType?
    var dietDate:Date?
    var dietTotalPrice = 0.0
    var dietFoodArray = [DietFood]()
    var dietFoodDeleteArray = [DietFood]()
    var dateFormatter = DateFormatter()
    var dietList: DietList?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* init date and dateForematter */
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dietDate = Date.init()
        setTimeTextField.text = dateFormatter.string(from: dietDate!)
        
        /* init dietTimePicker */
        dietTimePicker.datePickerMode = .dateAndTime
        dietTimePicker.date = Date()
        dietTimePicker.addTarget(self, action: #selector(timeUpdatedByDatePicker), for: .valueChanged)
        dietTimePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
        
        /* init setTimeTextField */
        setTimeTextField.inputView = dietTimePicker
        let toolBar = UIToolbar().ToolbarPicker(mySelect: #selector(self.dismissPicker))
        setTimeTextField.inputAccessoryView = toolBar
        
        /* init dietFoodTableView */
        dietFoodTableView.delegate = self
        dietFoodTableView.dataSource = self
        
        if(dietList != nil){    // if distList is presence. -> 目前是閱覽＆編輯模式
            dietStore = dietList?.store
            dietDate = dietList?.time
            dietType = dietList?.diettype
            dietStoreButton.setTitle(dietList?.store?.name, for: .normal)
            setTimeTextField.text = dateFormatter.string(from: dietDate!)
            dietTypeButton.setTitle(dietType?.name, for: .normal)
            dietStoreButton.isEnabled = false
            
            
            if(dietFoodArray.count == 0){
                for temp in dietList!.listfood!{
                    let food = temp as! ListFood
                    let dietFood = DietFood()
                    dietFood.name = food.name
                    dietFood.number = Int(food.number)
                    dietFood.type = food.type
                    dietFood.price = food.price
                    dietFood.listFood = food
                    dietFoodArray.append(dietFood)
                }
            }
        }
        else{   // if distList is presence. -> 目前是新增模式
            
        }

    }
    
    /* viewWillAppear need to reload data*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    
    /* reload data */
    func reloadData() {
        
        /* calulation the total price */
        dietTotalPrice = 0.0
        for item in dietFoodArray{
            dietTotalPrice += item.price! * Double(item.number!)
        }
        dietPriceLabel.text = "$ " + String(dietTotalPrice)
        
        dietFoodTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectStore", let StorVC = segue.destination as? StoreViewController {
            StorVC.selectMode = true
        }
        if segue.identifier == "SelectDietType", let dietTypeVC = segue.destination as? DietTypeViewController {
            dietTypeVC.selectMode = true
        }
        if segue.identifier == "SelectStoreFood", let storeFoodVC = segue.destination as? StoreFoodViewController {
            storeFoodVC.selectMode = true
            storeFoodVC.whichStore = dietStore
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

    @IBAction func addNewFoodAction(_ sender: Any) {
        let notificationName = Notification.Name("dietFoodUpdated")
        NotificationCenter.default.addObserver(self, selector: #selector(dietfoodUpdated(noti:)), name: notificationName, object: nil)
        self.performSegue(withIdentifier: "SelectStoreFood", sender: self)
    }
    
    @IBAction func saveThisDietAction(_ sender: Any) {
        
        if ((dietStore == nil) || (dietType == nil)) {
            let warn = UIAlertController(
                title: "錯誤",
                message: "您未選擇店家或類型！",
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
        
        if (dietFoodArray.count == 0) {
            let warn = UIAlertController(
                title: "錯誤",
                message: "您至少新增一筆餐點！",
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
        
        if let tempDietList = self.dietList {
            /*
            tempDietList.willChangeValue(forKey: "price")
            tempDietList.setValue(dietTotalPrice, forKey: "price")
            tempDietList.didChangeValue(forKey: "price")
            tempDietList.willChangeValue(forKey: "time")
            tempDietList.setValue(dietDate, forKey: "time")
            tempDietList.didChangeValue(forKey: "time")
            tempDietList.didSave()
             */
            tempDietList.price = dietTotalPrice
            tempDietList.time = dietDate
        }
            
        else{
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let dietList = DietList(context: managedContext)
            dietList.diettype = dietType
            dietList.time = dietDate
            dietList.store = dietStore
            dietList.price = dietTotalPrice
            
            do{
                try managedContext.save()
                //rint("Save succeed.")
                self.dietList = dietList
            }
            catch{
                print("Failed to save data.", error.localizedDescription)
            }
        }
        
        for dietFood in dietFoodArray{
            
            if dietFood.editFlag {
                if (dietFood.listFood != nil){
                    dietFood.listFood?.number = Int32(dietFood.number!)
                }
            }
            
            if (dietFood.listFood == nil){
                guard let foodManagedContext = appDelegate?.persistentContainer.viewContext else { return }
                let listFood = ListFood(context: foodManagedContext)
                
                listFood.belong = dietList
                listFood.name = dietFood.name
                listFood.number = Int32(dietFood.number!)
                listFood.price = dietFood.price!
                listFood.type = dietFood.type
                
                do{
                    try foodManagedContext.save()
                    dietFood.listFood = listFood
                    //rint("Save succeed.")
                }
                catch{
                    print("Failed to save data.", error.localizedDescription)
                }
            }
        }
        
        for dietFood in dietFoodDeleteArray{
            if let deleteListFoodItem = dietFood.listFood {
                guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
                managedContext.delete(deleteListFoodItem)
                do{
                    try managedContext.save()
                    //print("Data Deleted!")
                }
                catch{
                    print("Can't delete data: ", error.localizedDescription)
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
        //dietList?.diettype = dietType
        dietTypeButton.setTitle(dietType?.name, for: .normal)
    }
    
    @objc func timeUpdatedByDatePicker(datePicker: UIDatePicker) {
        datePicker.maximumDate = Date()
        dietDate = datePicker.date
        //dietList?.time = dietDate
        setTimeTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func dietfoodUpdated(noti: Notification) {
        print("Get Notification")
        let getFood = noti.object as? Food

        // 建立一個提示框
        let alertController = UIAlertController(
            title: "數量",
            message: "請輸入"+getFood!.name!+"的數量",
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let returnAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                let foodNumberString = alertController.textFields?[0].text
                if(foodNumberString?.count==0){
                    let warn = UIAlertController(
                        title: "錯誤",
                        message: "輸入欄位有留空，請重新選擇並輸入！",
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
                else{
                    
                    var foodNumber = -1
                    if let tempString = foodNumberString{
                        foodNumber = Int(tempString)!
                        print(foodNumber)
                    }
                    
                    let dietFood = DietFood()
                    
                    if(foodNumber != -1) {
                        dietFood.name = getFood?.name
                        dietFood.type = getFood?.type
                        dietFood.price = getFood!.price
                        dietFood.number = foodNumber
                        self.dietFoodArray.append(dietFood)
                        self.reloadData()
                    }
                    else {return}
                }
        })
        alertController.addAction(returnAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "數量"
            textField.delegate = self
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
            //textField.keyboardType = UIKeyboardType.phonePad
        }
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    @objc func dismissPicker() {
        
        view.endEditing(true)
        
    }
    
    /*TableView Function (Head) */
    // 設定TableViewCell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dietFoodArray.count
    }
    
    // 設定TableViewCell的初始化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DietFoodCell", for: indexPath) as! DietFoodViewCell
        let dietFood = dietFoodArray[indexPath.row]
        //cell.accessoryType = .checkmark
        cell.name.text =  dietFood.name
        cell.type.text = dietFood.type?.name
        cell.number.text = String(dietFood.number!)
        cell.price.text = String(dietFood.price! * Double(dietFood.number!))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
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
            self.dietFoodDeleteArray.append(self.dietFoodArray[indexPath.row])
            self.dietFoodArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadData()
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        let editAction = UITableViewRowAction(style: .destructive, title: "修改") { (action, indexPath) in
            /*self.dietFoodArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)*/
            // 建立一個提示框
            let alertController = UIAlertController(
                title: "數量",
                message: "請輸入"+self.dietFoodArray[indexPath.row].name!+"的數量",
                preferredStyle: .alert)
            
            // 建立[確認]按鈕
            let returnAction = UIAlertAction(
                title: "確認",
                style: .default,
                handler: {
                    (action: UIAlertAction!) -> Void in
                    let foodNumberString = alertController.textFields?[0].text
                    if(foodNumberString?.count==0){
                        let warn = UIAlertController(
                            title: "錯誤",
                            message: "輸入欄位有留空！\n\n請重新選擇並輸入！",
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
                    else{
                        
                        var foodNumber = -1
                        if let tempString = foodNumberString{
                            foodNumber = Int(tempString)!
                            //print(foodNumber)
                        }
                        
                        
                        if(foodNumber != -1) {
                            self.dietFoodArray[indexPath.row].number = foodNumber
                            self.dietFoodArray[indexPath.row].editFlag = true
                        }
                        else {return}
                        
                        self.reloadData()
                    }
            })
            alertController.addAction(returnAction)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "數量"
                textField.delegate = self
                textField.text = String(self.dietFoodArray[indexPath.row].number!)
                textField.clearButtonMode = .whileEditing
                textField.keyboardType = .numberPad
                textField.returnKeyType = .done
                //textField.keyboardType = UIKeyboardType.phonePad
            }
            
            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return [deleteAction,editAction]
    }
    
    // 表格內Cell的短按動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)

    }
    /*TableView Function (Tail) */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIToolbar {
    func ToolbarPicker(mySelect: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

class DietFoodViewCell: UITableViewCell {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var price: UILabel!
}

class DietFood{
    var name:String?
    var type:FoodType?
    var price:Double?
    var number:Int?
    
    var listFood:ListFood?
    var editFlag = false
}

