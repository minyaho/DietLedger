//
//  ContentViewController.swift
//  ACTabScrollView
//
//  Created by Azure Chen on 5/19/16.
//  Copyright © 2016 AzureChen. All rights reserved.
//

import UIKit
import CoreData

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // Varible
    var dayIndex = 0
    var date = Date()
    var dietListArray = [DietList]()
    
    let dateFormat:DateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    /*var category: NewsCategory? {
        didSet {
            for news in MockData.newsArray {
                if (news.category == category || category == .all) {
                    newsArray.append(news)
                }
            }
        }
    }*/
    /*
    var title_name = ["麵包麵包麵包麵包麵包麵包麵包", "漢堡", "熱狗"]
    var store_name = ["早安美滋城","幸福漢堡店","麥當勞"]
    var type_name = ["早","中","晚"]
    var time_name = ["9:33","11:55","19:30"]
    var money_name = ["700","55845","545"]*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()
        dietListArray.sort(by: <)
        tableView.reloadData()
    }
    
    // 已經收到記憶體警告
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        //print("? didReceiveMemoryWarning")
    }
    /*
    // 載入檢視
    override func loadView() {
        
        super.loadView()
        
        print("1 loadView")
    }
    
    // 檢視即將出現
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("3 viewWillAppear")
    }
    
    // 檢視即將佈局
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("4 viewWillLayoutSubviews")
    }
    
    // 檢視已經佈局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("5 viewDidLayoutSubviews")
    }
    
    // 檢視已經出現
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("6 viewDidAppear")
    }
    
    // 檢視即將消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("7 viewWillDisappear")
    }
    
    // 檢視已經消失
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view = nil
        print("8 viewDidDisappear")
    }
    
    // 釋放檢視控制器
    deinit
    {
        print("9 \(self) 被釋放")
    }*/
    
    
    /* Fuction (Head) */
    // 同步更新Store的Data
    func syncData() {
        fetchData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(dietListArray.count>0){     // 資料量大於0 顯示TableView
                    tableView.isHidden = false
                }else{                      // 反之隱藏TableView
                    tableView.isHidden = true;
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dietListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let news = newsArray[(indexPath as NSIndexPath).row]
        
        var tempString = ""
        for listFood in (dietListArray[indexPath.row].listfood)!{
            let food = listFood as! ListFood
            tempString = tempString + " " + food.name!
        }
        if(tempString.count>0){
            let index = tempString.index(tempString.startIndex, offsetBy: 1)
            tempString = String(tempString[index...])
        }
        else
        {
            tempString = "（空）"
        }
        
        // set the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "DietListCell") as! ContentTableViewCell
        //cell.thumbnailImageView.image = UIImage(named: "thumbnail-\(news.id)")
        dateFormat.dateFormat = "HH:mm"
        cell.timeLabel.text = dateFormat.string(from: dietListArray[indexPath.row].time!)
        //print(dietListArrat[indexPath.row].time!)
        cell.itemLabel.text = tempString
        cell.moneyLabel.text = "$ " + String(dietListArray[indexPath.row].price)
        cell.storeLabel.text = dietListArray[indexPath.row].store?.name
        cell.type.text = dietListArray[indexPath.row].diettype?.name
        cell.type.layer.backgroundColor = UIColor.orange.cgColor
        cell.type.layer.cornerRadius = 25
        cell.type.layer.borderWidth = 2
        cell.type.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "DietViewStoryboardID") as? DietViewController
        {
            vc.dietList = dietListArray[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        
        let label = UILabel()
        dateFormat.dateFormat = "yyyy/MM/dd"
        label.text = dateFormat.string(from: date)
        label.textColor = UIColor.white
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
        } else {
            label.font = UIFont.systemFont(ofSize: 16)
        }
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 18, y: 10)
        
        view.addSubview(label)
        
        return view
    }*/

}

extension ContentViewController{
    
    /* CoreData Store Entity (Head)*/
    // 抓取Store全部資料
    func fetchData(completion: (_ complete: Bool) -> ()) {
        //print(date)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: date)
        var startDateComponents = DateComponents()
        startDateComponents.year = dateComponents.year
        startDateComponents.month = dateComponents.month
        startDateComponents.day = dayIndex
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.timeZone = TimeZone.current
        let startDate = calendar.date(from: startDateComponents)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
        dateFormat.dateFormat = "MM/dd HH:mm:ss"
//        print("****")
        //print(dateFormat.string(from: startDate!))
        //print(dateFormat.string(from: endDate!))
//        print(dateFormat.string(from: endDate!))
//        print("****")
        //print(startDate!.timeIntervalSince1970)
        //print(endDate!.timeIntervalSince1970)
        
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DietList")
        request.predicate = NSPredicate(format: "(time > %@) AND (time <= %@)", startDate! as NSDate, endDate! as NSDate)
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
    func deleteData(indexPath: IndexPath){
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(dietListArray[indexPath.row])
        do{
            try managedContext.save()
            //print("Data Deleted!")
        }
        catch{
            print("Can't delete data: ", error.localizedDescription)
        }
    }
    
    // 找尋Store內name包含string的資料
    func searchDietList(string: String){
        
        if(string != ""){
            
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DietList")
            
            request.predicate = NSPredicate.init(format: "name like[c] %@", "*"+string+"*")
            do{
                dietListArray = try managedContext.fetch(request) as! [DietList]
                if(dietListArray.count>0){
                    tableView.isHidden = false
                }else{
                    tableView.isHidden = true;
                }
                tableView.reloadData()
                //print("Data fetch has no issue!")
            }
            catch{
                print("Can't fetch data: ", error.localizedDescription)
            }
        }else{
            syncData()
            tableView.reloadData()
        }
    }
    /* CoreData Store Entity (Tail)*/
}


class ContentTableViewCell: UITableViewCell {
    
    @IBOutlet var type: UILabel!
    
    @IBOutlet var itemLabel: UILabel!
    
    @IBOutlet var storeLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var moneyLabel: UILabel!
}

extension DietList{
    static func < (x: DietList, y: DietList) -> Bool {
        let tempX = Double(x.time!.timeIntervalSince1970)
        let tempY = Double(y.time!.timeIntervalSince1970)
        return tempX < tempY
    }
}
