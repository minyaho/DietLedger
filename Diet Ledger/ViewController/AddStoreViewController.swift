//
//  AddStoreViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2019/12/19.
//  Copyright © 2019 MinyaHo. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class AddStoreViewController: UIViewController, MKMapViewDelegate ,CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var storeMapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    
    let localtionManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.layer.backgroundColor = UIColor.orange.cgColor
        nameLabel.layer.cornerRadius = 10
        phoneLabel.layer.backgroundColor = UIColor.orange.cgColor
        phoneLabel.layer.cornerRadius = 10
        lonLabel.layer.backgroundColor = UIColor.orange.cgColor
        lonLabel.layer.cornerRadius = 10
        latLabel.layer.backgroundColor = UIColor.orange.cgColor
        latLabel.layer.cornerRadius = 10
        
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        phoneTextField.delegate = self
        phoneTextField.returnKeyType = .done
        phoneTextField.keyboardType = .numberPad
        latTextField.delegate = self
        latTextField.keyboardType = .numberPad
        lonTextField.delegate = self
        lonTextField.keyboardType = .numberPad
        
        
        localtionManger.delegate = self
        localtionManger.distanceFilter = kCLLocationAccuracyNearestTenMeters
        localtionManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        ensureGpsEnbale()
        
        storeMapView.delegate = self
        storeMapView.mapType = .standard
        storeMapView.showsUserLocation = true
        storeMapView.isZoomEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        localtionManger.stopUpdatingLocation()
    }
    
    func ensureGpsEnbale()  {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            localtionManger.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            localtionManger.startUpdatingLocation()
        case .denied:
            let alertController = UIAlertController(
                title: "定位權限未開啟",
                message: "如需要變更權限，請至 設定＞隱私權＞定位服務 開啟。若無提供權限則必須自行填入經緯度資訊。",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default, handler: {(
                action: UIAlertAction!) -> Void in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocaltion = locations[0] as CLLocation
        
        latTextField.text = String(currentLocaltion.coordinate.latitude)
        latTextField.isEnabled = false
        lonTextField.text = String(currentLocaltion.coordinate.longitude)
        lonTextField.isEnabled = false
        let showMapLocation = CLLocationCoordinate2D(latitude: currentLocaltion.coordinate.latitude, longitude: currentLocaltion.coordinate.longitude)
        print(showMapLocation)
        let _span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        storeMapView.setRegion(MKCoordinateRegion(center: showMapLocation,span: _span), animated: true)
    }
    
    
    /* TextField Function (Head) */
     @objc func dismissKeyboard() {
        self.view.endEditing(true)
     }
     
     func textFieldDidBeginEditing(_ textField: UITextField){
        //print("textFieldDidBeginEditing:" + textField.text!)
     }
     
     // 可能進入結束編輯狀態
     func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("textFieldShouldEndEditing:" + textField.text!)
        return true
     }
     
     // 結束編輯狀態(意指完成輸入或離開焦點)
     func textFieldDidEndEditing(_ textField: UITextField) {
        //print("textFieldDidEndEditing:" + textField.text!)
     }
     
     // 當按下右下角的return鍵時觸發
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 關閉鍵盤
        return true
     }
     
     // 設定欄位是否可以清除
     func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
     }
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
     return true
     
     }
     /* TextField Function (Tail) */
    
    @IBAction func SaveStoreAction(_ sender: Any) {
        
        if((nameTextField.text?.count==0) || (latTextField.text?.count==0) || (lonTextField.text?.count==0)){
            var alertMessage = ""
            
            if(nameTextField.text?.count==0){ alertMessage = alertMessage + "名稱 " }
            if(latTextField.text?.count==0){ alertMessage = alertMessage + "緯度 " }
            if(lonTextField.text?.count==0){ alertMessage = alertMessage + "經度 " }
            
            let alertController = UIAlertController(
                title: "輸入欄位錯誤",
                message: "欄位 " + alertMessage + "未填 " ,
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "返回", style: .default, handler: {(
                action: UIAlertAction!) -> Void in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
            let store = Store(context: managedContext)
            store.name = nameTextField.text
        
            if let latitude:Double = Double(latTextField.text!)
            {
                store.latitude = latitude
            }
        

            if let longitude:Double = Double(lonTextField.text!)
            {
                store.longitude = longitude
            }
        
            if((phoneTextField.text) != ""){
                store.phone = phoneTextField.text
            }
        
            do{
                try managedContext.save()
                //rint("Save succeed.")
            }
            catch{
                print("Failed to save data.", error.localizedDescription)
            }
        
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}


