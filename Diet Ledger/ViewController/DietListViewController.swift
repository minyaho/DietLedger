//
//  DietListViewController.swift
//  Diet Ledger
//
//  Created by mac09 on 2019/12/18.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class DietListViewController: UIViewController, ACTabScrollViewDelegate, ACTabScrollViewDataSource{

    // Outlet
    @IBOutlet weak var tabScrollView: ACTabScrollView!
    @IBOutlet weak var titleDateLabel: UILabel!
    @IBOutlet var thisMonthCostLabel: UILabel!
    @IBOutlet var thisMonthDietNumberLabel: UILabel!
    
    // Varible
    /*
     calculatedDate: 暫時存放計算完的時間
     */
    var contentViews: [UIView] = []
    var calculatedDate = Date()
    var labelData: [String] = []
    var dateData: [Date] = []
    var dietListArray: [DietList] = []
    
    // Constant
    /*
     now: 當下時間
     dateFormat: 時間格式(輸出入時間 String <-> Date)
     calendar: 日期計算
     */
    let now:Date = Date()
    let dateFormat:DateFormatter = DateFormatter()
    let calendar = Calendar.current
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // 設定titleDateLabel
        /*
            0: 初始化dateFormat 設定格式為“XXXX XX月”
         */
        dateFormat.dateFormat = "yyyy年 MM月"
        titleDateLabel.text = dateFormat.string(from: calculatedDate)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: calculatedDate)
        
        /* 初始化TabScrollView所需資料 */
        reloadTabScrollView()
        
        /* ACTabScrollView 初始化設定 (Head) */
        tabScrollView.defaultPage = Int(dateComponents.day!)-1
        tabScrollView.arrowIndicator = true
        tabScrollView.tabSectionBackgroundColor = UIColor(red: 255.0 / 255, green: 222.0 / 255, blue: 173.0 / 255, alpha: 1)
        //tabScrollView.tabSectionHeight = 60
        tabScrollView.pagingEnabled = true
        tabScrollView.cachedPageLimit = 3
        
        tabScrollView.delegate = self
        tabScrollView.dataSource = self // Do any additional setup after loading the view.
        /* ACTabScrollView 初始化設定 (Tail) */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        syncData()
    }
    
    func syncData() {
        fetchData{ (done) in
            if done {
                var tempValue = 0.0
                for diet in dietListArray{
                    tempValue += diet.price
                }
                thisMonthCostLabel.text = "$" + String(tempValue)
                thisMonthDietNumberLabel.text = String(dietListArray.count)
            }
        }
    }
    
    /* IBAction (Head) */
    @IBAction func goToLastMonthAction(_ sender: Any) {
        dateFormat.dateFormat = "yyyy年 MM月"
        calculatedDate = calendar.date(byAdding: .month, value: -1, to: calculatedDate)!
        titleDateLabel.text = dateFormat.string(from: calculatedDate)
        syncData()
        reloadTabScrollView()
    }
    
    @IBAction func goToNextMonthAction(_ sender: Any) {
        dateFormat.dateFormat = "yyyy年 MM月"
        calculatedDate = calendar.date(byAdding: .month, value: 1, to: calculatedDate)!
        titleDateLabel.text = dateFormat.string(from: calculatedDate)
        syncData()
        reloadTabScrollView()
    }
    
    /* IBAction (Tail) */
    
    // MARK: ACTabScrollViewDelegate
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        //print(index)
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
    }
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return labelData.count
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        let label = UILabel()
        label.text = String(describing: labelData[index]).uppercased()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
        } else {
            label.font = UIFont.systemFont(ofSize: 16)
        }
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 0
        
        // if the size of your tab is not fixed, you can adjust the size by the following way.
        label.sizeToFit() // resize the label to the size of content
        label.frame.size = CGSize(width: /*label.frame.size.width + 28*/60, height: label.frame.size.height + 18) // add some paddings
        
        return label
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        return contentViews[index]
    }

    func makeTabScrollLabelData(data :Date) -> [String] {
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: data)
        
        var startDateComponents = DateComponents()
        startDateComponents.year = dateComponents.year
        startDateComponents.month = dateComponents.month
        let startDate = calendar.date(from: startDateComponents)
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)
        var diffDateComponents = calendar.dateComponents([.day], from: startDate!, to: endDate!)
        //print(diffDateComponents.day!)
        
        var tempLabelData: [String] = []
        let days = Int(diffDateComponents.day!)
        let tempDateFormat:DateFormatter = DateFormatter()
        tempDateFormat.dateFormat = "EE\ndd"
        
        for day in 0...(days-1) {
            let tempDate = calendar.date(byAdding: .day, value: day, to: startDate!)
            let tempString = tempDateFormat.string(from: tempDate!)
            tempLabelData.append(tempString)
            //print(tempLabelData[day])
        }
        return tempLabelData
    }
    
    func roadContentViews(labelData: [String]) -> [UIView] {
        var tempContentViews = [UIView]()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: calculatedDate)
        var startDateComponents = DateComponents()
        startDateComponents.year = dateComponents.year
        startDateComponents.month = dateComponents.month
        startDateComponents.hour = 7
        startDateComponents.minute = 0
        startDateComponents.second = 0
        let startDate = calendar.date(from: startDateComponents)
        
        var index = 1
        for _ in labelData {
            let vc = storyboard.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
            vc.dayIndex = index
            vc.date = calendar.date(byAdding: .day, value: index, to: startDate!)!
            addChild(vc) // don't forget, it's very important
            tempContentViews.append(vc.view)
            index+=1
        }
        return tempContentViews
    }
    
    func reloadTabScrollView(){
        labelData.removeAll()
        contentViews.removeAll()
        labelData = makeTabScrollLabelData(data: calculatedDate)
        contentViews = roadContentViews(labelData: labelData)
        self.tabScrollView.reloadData()
    }
}

extension DietListViewController{
    
    func fetchData(completion: (_ complete: Bool) -> ()) {
        //print(date)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: calculatedDate)
        var startDateComponents = DateComponents()
        startDateComponents.year = dateComponents.year
        startDateComponents.month = dateComponents.month
        startDateComponents.day = 1
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        startDateComponents.timeZone = TimeZone.current
        let startDate = calendar.date(from: startDateComponents)
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)
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
}
