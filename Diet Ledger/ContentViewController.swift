//
//  ContentViewController.swift
//  ACTabScrollView
//
//  Created by Azure Chen on 5/19/16.
//  Copyright © 2016 AzureChen. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var category:String = ""
    /*var category: NewsCategory? {
        didSet {
            for news in MockData.newsArray {
                if (news.category == category || category == .all) {
                    newsArray.append(news)
                }
            }
        }
    }*/
    var title_name = ["麵包", "漢堡", "熱狗"]
    var store_name = ["早安美滋城","幸福漢堡店","麥當勞"]
    var type_name = ["早","中","晚"]
    var time_name = ["9:33","11:55","19:30"]
    var money_name = ["700","55845","545"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return title_name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let news = newsArray[(indexPath as NSIndexPath).row]
        
        // set the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "DietListCell") as! ContentTableViewCell
        //cell.thumbnailImageView.image = UIImage(named: "thumbnail-\(news.id)")
        cell.timeLabel.text = time_name[indexPath.row]
        cell.itemLabel.text = title_name[indexPath.row]
        cell.moneyLabel.text = "$"+money_name[indexPath.row]
        cell.type.text = String(type_name[indexPath.row])
        cell.type.layer.backgroundColor = UIColor.orange.cgColor
        cell.type.layer.cornerRadius = 30
        cell.type.layer.borderWidth = 2
        cell.type.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 61.0 / 255, green: 66.0 / 255, blue: 77.0 / 255, alpha: 1.0)
        
        let label = UILabel()
        label.text = category
        label.textColor = UIColor.white
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.thin)
        } else {
            label.font = UIFont.systemFont(ofSize: 17)
        }
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 18, y: 13)
        
        view.addSubview(label)
        
        return view
    }

}

class ContentTableViewCell: UITableViewCell {
    
    @IBOutlet var type: UILabel!
    
    @IBOutlet var itemLabel: UILabel!
    
    @IBOutlet var storeLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var moneyLabel: UILabel!
}
