//
//  NextDietViewController.swift
//  Diet Ledger
//
//  Created by mac09 on 2020/1/6.
//  Copyright © 2020 MinyaHo. All rights reserved.
//

import UIKit
import CoreData

class NextDietViewController: UIViewController {

    @IBOutlet var foodNameLabel: UILabel!
    @IBOutlet var storeFoodName: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var typeButton: UIButton!
    
    var randomArray = [Int]()
    var foodArray = [Food]()
    var hasFood = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncData()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func selectAction(_ sender: Any) {
        
        if hasFood {
            let rad = Int.random(in: 0...(foodArray.count-1))
            let food = foodArray[rad]
            foodNameLabel.text = food.name
            storeFoodName.text = food.productor?.name
            priceLabel.text = "$ " + String(food.price)
            typeButton.setTitle(food.type?.name, for: .normal)
        }
        else{
            let warn = UIAlertController(
                title: "錯誤",
                message: "沒有餐點數據！",
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
        }
    }
    
    func syncData() {
        fetchFoodData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(foodArray.count>0){     // 資料量大於0 顯示TableView
                    hasFood = true
                    //randomArray.removeAll()
                    
                    
                    
                }else{                      // 反之隱藏TableView
                    hasFood = false
                }
            }
        }
    }
    
    func fetchFoodData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
        //request.predicate = NSPredicate(format: "productor == %@", whichStore!)
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
}

class foodOrder: NSObject{
    var food:Food?
    var index:Int?
}
