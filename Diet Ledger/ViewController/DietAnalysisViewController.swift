//
//  DietAnalysisViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2020/1/4.
//  Copyright © 2020 MinyaHo. All rights reserved.
//

import UIKit

class DietAnalysisViewController: UIViewController {

    @IBOutlet weak var costView: UIView!
    @IBOutlet weak var typeView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let chartViewWidth = self.costView.frame.size.width
        let chartViewHeight = self.costView.frame.size.height
        let aaChartView = AAChartView()
        aaChartView.frame = CGRect(x: 0, y: 0, width: chartViewWidth, height: chartViewHeight)
        self.costView.addSubview(aaChartView)
        
        let chartModel = AAChartModel()
            .chartType(.line)//圖表類型
            .title("城市天氣變化")//圖表主標題
            .subtitle("2020年09月18日")//圖表副標題
            .inverted(false)//是否翻轉圖形
            .yAxisTitle("攝氏度")// Y 軸標題
            .legendEnabled(true)//是否啟用圖表的圖例(圖表底部的可點擊的小圓點)
            .tooltipValueSuffix("攝氏度")//浮動提示框單位後綴
            .categories(["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])//主題顏色數組
            .series([
                AASeriesElement()
                    .name("東京")
                    .data([7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]),
                AASeriesElement()
                    .name("紐約")
                    .data([0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]),
                AASeriesElement()
                    .name("柏林")
                    .data([0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]),
                AASeriesElement()
                    .name("倫敦")
                    .data([3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]),
                ])
        aaChartView.aa_drawChartWithChartModel(chartModel)
        
        
        let bchartViewWidth = self.typeView.frame.size.width
        let bchartViewHeight = self.typeView.frame.size.height
        let baaChartView = AAChartView()
        baaChartView.frame = CGRect(x: 0, y: 0, width: bchartViewWidth, height: bchartViewHeight)
        self.typeView.addSubview(baaChartView)
            
        let bchartModel = AAChartModel()
                .chartType(.line)//圖表類型
                .title("城市天氣變化")//圖表主標題
                .subtitle("2020年09月18日")//圖表副標題
                .inverted(false)//是否翻轉圖形
                .yAxisTitle("攝氏度")// Y 軸標題
                .legendEnabled(true)//是否啟用圖表的圖例(圖表底部的可點擊的小圓點)
                .tooltipValueSuffix("攝氏度")//浮動提示框單位後綴
                .categories(["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
                .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0"])//主題顏色數組
                .series([
                    AASeriesElement()
                        .name("東京")
                        .data([7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]),
                    AASeriesElement()
                        .name("紐約")
                        .data([0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]),
                    AASeriesElement()
                        .name("柏林")
                        .data([0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]),
                    AASeriesElement()
                        .name("倫敦")
                        .data([3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]),
                    ])
        baaChartView.aa_drawChartWithChartModel(bchartModel)
        */
    }
}
