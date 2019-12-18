//
//  DietListViewController.swift
//  Diet Ledger
//
//  Created by mac09 on 2019/12/18.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit

class DietListViewController: UIViewController, ACTabScrollViewDelegate, ACTabScrollViewDataSource{

    @IBOutlet weak var tabScrollView: ACTabScrollView!
    
    var label_name = ["週一\n1","週二\n2","週三\n3","週四\n4","週五\n5","週六\n6","週日\n7"]
    var contentViews: [UIView] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tabScrollView.defaultPage = 1
        tabScrollView.arrowIndicator = true
        tabScrollView.tabSectionBackgroundColor = UIColor(red: 255.0 / 255, green: 222.0 / 255, blue: 173.0 / 255, alpha: 1)
        //tabScrollView.tabSectionHeight = 60
        tabScrollView.pagingEnabled = true
        tabScrollView.cachedPageLimit = 3
        
        tabScrollView.delegate = self
        tabScrollView.dataSource = self       // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        for category in label_name {
            let vc = storyboard.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
            vc.category = category
            
            addChild(vc) // don't forget, it's very important
            contentViews.append(vc.view)
        }
    }
    
    
    
    // MARK: ACTabScrollViewDelegate
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        print(index)
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
    }
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return label_name.count
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        let label = UILabel()
        label.text = String(describing: label_name[index]).uppercased()
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
        label.frame.size = CGSize(width: label.frame.size.width + 28, height: label.frame.size.height + 36) // add some paddings
        
        return label
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        return contentViews[index]
    }

}
