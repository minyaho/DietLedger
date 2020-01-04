//
//  StoreViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/18.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, CLLocationManagerDelegate{
    
    // Outlet
    @IBOutlet weak var storeTableView: UITableView!
    @IBOutlet weak var storeSearchBar: UISearchBar!
    

    // Varables
    var selectMode = false
    var storeArray = [Store]()
    var selectStore:Store?
    var showDistanceMode = 0 // 0: Not Show, 1:Show
    var currentLocaltion:CLLocation?
    
    // Constants
    let myEntityName = "Store"
    let localtionManger = CLLocationManager()
    
    
    /* ViewFunction (Head) */
    // ViewFunction DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // storeTableView 設定
        storeTableView.delegate = self
        storeTableView.dataSource = self
        storeTableView.isHidden = true
        
        // findStoreTextField 設定
        /*
        findStoreTextField.delegate = self
        findStoreTextField.clearButtonMode = .whileEditing  // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        findStoreTextField.placeholder = "請輸入店家名稱"         // 尚未輸入時的預設顯示提示文字
        findStoreTextField.returnKeyType = .done            // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        findStoreTextField.leftView = setIcon(image: #imageLiteral(resourceName: "TextFieldIconSearch"))
        findStoreTextField.leftViewMode = .always*/
        //findStoreTextField.textColor = UIColor.whiteColor() // 輸入文字的顏色
        //findStoreTextField.backgroundColor = UIColor.lightGrayColor // UITextField 的背景顏色
        
        // 註冊tab事件，點選瑩幕任一處可關閉瑩幕小鍵盤
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //self.view.addGestureRecognizer(tap)
        
        //绑定对长按的响应
        //let longPress =  UILongPressGestureRecognizer(target:self,action:#selector(tableviewCellLongPressed(gestureRecognizer:)))
        //代理
        //longPress.delegate = self as? UIGestureRecognizerDelegate
        //longPress.minimumPressDuration = 1.0
        //将长按手势添加到需要实现长按操作的视图里
        //self.storeTableView!.addGestureRecognizer(longPress)
        
        // storeSearchBar 設定
        storeSearchBar.delegate = self
        
        localtionManger.delegate = self
        localtionManger.distanceFilter = kCLLocationAccuracyNearestTenMeters
        localtionManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        ensureGpsEnbale()
        
        // 第一次資料更新
        syncData()
        if (showDistanceMode == 1) {storeArray.sort(by: <);}
        storeTableView.reloadData()
    }
    
    // ViewFunction DidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        syncData()
        if (showDistanceMode == 1) {storeArray.sort(by: <);}
        storeTableView.reloadData()
    }
    /* ViewFunction (Tail) */
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        localtionManger.stopUpdatingLocation()
    }
    
    /* IBAction Fuction (Head)*/
    

    /* IBAction Fuction (Tail)*/

    /* Fuction (Head) */
    
    func ensureGpsEnbale()  {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //localtionManger.requestWhenInUseAuthorization()
            //distanceLabel.text = "GPS未授權"
            showDistanceMode = 0
            break
        case .authorizedWhenInUse:
            localtionManger.startUpdatingLocation()
            showDistanceMode = 1
            break
        case .denied:
            //distanceLabel.text = "GPS未開啟"
            showDistanceMode = 0
            break
        default:
            break
        }
    }
    
    /* 更新GPS位置 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocaltion = locations[0] as CLLocation
        for store in storeArray{
            let targetLocation = CLLocation.init(latitude: store.latitude, longitude: store.longitude)
            let distance:CLLocationDistance = currentLocaltion!.distance(from: targetLocation)
            store.distance = distance
        }
        
        for store in storeArray{
            let targetLocation = CLLocation.init(latitude: store.latitude, longitude: store.longitude)
            //let eLocation = CLLocationCoordinate2D(latitude: selectStore!.latitude, longitude: selectStore!.longitude)
            //let sLocation = CLLocationCoordinate2D(latitude: currentLocaltion.coordinate.latitude, longitude: currentLocaltion.coordinate.longitude)
            let distance:CLLocationDistance = currentLocaltion!.distance(from: targetLocation)
            store.distance = distance;
        }
        
        storeArray.sort(by: <)
        storeTableView.reloadData()
    }
    
    // 同步更新Store的Data
    func syncData() {
        fetchData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(storeArray.count>0){     // 資料量大於0 顯示TableView
                    storeTableView.isHidden = false
                }else{                      // 反之隱藏TableView
                    storeTableView.isHidden = true;
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StoreDetail", let StoreDetail = segue.destination as? StoreDetailViewController {
            StoreDetail.selectStore = selectStore
        }
    }
    /* Fuction (Tail) */
    
    /*TableView Function (Head) */
    // 設定TableViewCell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeArray.count
    }
    
    // 設定TableViewCell的初始化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreListCell", for: indexPath) as UITableViewCell
        let store = storeArray[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = store.name
        
        if((showDistanceMode == 1) && (currentLocaltion != nil)){
            let targetLocation = CLLocation.init(latitude: store.latitude, longitude: store.longitude)
            //let eLocation = CLLocationCoordinate2D(latitude: selectStore!.latitude, longitude: selectStore!.longitude)
            //let sLocation = CLLocationCoordinate2D(latitude: currentLocaltion.coordinate.latitude, longitude: currentLocaltion.coordinate.longitude)
            let distance:CLLocationDistance = currentLocaltion!.distance(from: targetLocation)
            store.distance = distance
            if(distance < 10){
                cell.detailTextLabel?.text = "小於 10 M"
            }
            else if(distance < 1000)
            {
                cell.detailTextLabel?.text = String(distance.rounding(toDecimal: 2)) + " M"
            }
            else if(distance >= 1000)
            {
                cell.detailTextLabel?.text = String((distance/1000).rounding(toDecimal: 2)) + " KM"
            }
        }
        else{
            cell.detailTextLabel?.text = String(store.longitude.rounding(toDecimal: 3)) + ", " + String(store.latitude.rounding(toDecimal: 3))
        }
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
        
        /*let editAction = UITableViewRowAction(style: .destructive, title: "修改") { (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.syncData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)*/
        //return [deleteAction,editAction]
        return [deleteAction]
    }
    
    // 表格內Cell的短按動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(
            at: indexPath, animated: true)
        if(!selectMode){
            //let name = storeArray[indexPath.row].name
            //print("選擇的是 \(String(describing: name))")
            selectStore = storeArray[indexPath.row]
            self.performSegue(withIdentifier: "StoreDetail", sender: self)
        }else{
            print("Post Notification")
            selectStore = storeArray[indexPath.row]
            let notificationName = Notification.Name("storeUpdated")
            NotificationCenter.default.post(name: notificationName, object: selectStore, userInfo: ["store":self.selectStore!]) //傳一個名稱叫”store”的selectStore值過去
            
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // 點選 Accessory 按鈕後執行的動作
    // 必須設置 cell 的 accessoryType
    // 設置為 .DisclosureIndicator (向右箭頭)之外都會觸發
    //func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    //    let name = storeArray[indexPath.row].name
    //    print("按下的是 \(String(describing: name)) 的 detail")
    //}
    
    // 長按表格動作
//    @objc func tableviewCellLongPressed(gestureRecognizer:UILongPressGestureRecognizer)
//    {
//        if (gestureRecognizer.state == UIGestureRecognizer.State.ended)
//        {
//            //在正常状态和编辑状态之间切换
//            if(self.storeTableView!.isEditing == false){
//                self.storeTableView!.setEditing(true, animated:true)
//            }
//            else{
//                self.storeTableView!.setEditing(false, animated:true)
//            }
//        }
//    }
    
    /*TableView Function (Tail) */
    
    
    /*TextField Function (Head)
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        print("textFieldDidBeginEditing:" + textField.text!)
    }
    
    // 可能進入結束編輯狀態
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing:" + textField.text!)
        return true
    }
    
    // 結束編輯狀態(意指完成輸入或離開焦點)
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing:" + textField.text!)
    }
    
    // 當按下右下角的return鍵時觸發
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 關閉鍵盤
        searchStore(string: textField.text!)
        return true
    }
    
    // 設定欄位是否可以清除
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //print(textField.text!)
        searchStore(string: textField.text!)
        return true

    }
    
    func setIcon(image: UIImage) -> UIView {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = #imageLiteral(resourceName: "TextFieldIconSearch")
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        return iconContainerView
    }
    TextField Function (Tail) */

    /*SearchBar Function (Head) */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStore(string: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    /*SearchBar Function (Tail) */
}

extension StoreViewController{
    
    /* CoreData Store Entity (Head)*/
    // 抓取Store全部資料
    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
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
    
    // 刪除Store內的某一筆資料
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
    
    // 找尋Store內name包含string的資料
    func searchStore(string: String){
        
        if(string != ""){
            
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: myEntityName)
            
            request.predicate = NSPredicate.init(format: "name like[c] %@", "*"+string+"*")
            do{
                storeArray = try managedContext.fetch(request) as! [Store]
                if(storeArray.count>0){
                    storeTableView.isHidden = false
                }else{
                    storeTableView.isHidden = true;
                }
                storeTableView.reloadData()
                //print("Data fetch has no issue!")
            }
            catch{
                print("Can't fetch data: ", error.localizedDescription)
            }
        }else{
            syncData()
            storeTableView.reloadData()
        }
    }
    /* CoreData Store Entity (Tail)*/
}

extension Double {
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}

extension Store{
    static func < (x: Store, y: Store) -> Bool {
        let tempX = x.distance
        let tempY = y.distance
        return tempX < tempY
    }
}
