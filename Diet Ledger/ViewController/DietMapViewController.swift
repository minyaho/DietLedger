//
//  DietMapViewController.swift
//  Diet Ledger
//
//  Created by eb211-21 on 2020/1/4.
//  Copyright © 2020 MinyaHo. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class DietMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var dietMapView: MKMapView!
    
    var storeArray = [Store]()
    var selectStore:Store?
    
    let localtionManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localtionManger.delegate = self
        localtionManger.distanceFilter = kCLLocationAccuracyHundredMeters
        localtionManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        ensureGpsEnbale()
        
        dietMapView.delegate = self
        dietMapView.mapType = .standard
        dietMapView.showsUserLocation = true
        dietMapView.isZoomEnabled = true
        
        syncData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncData()                  
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        localtionManger.stopUpdatingLocation()
    }
    
    func ensureGpsEnbale()  {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            localtionManger.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            localtionManger.startUpdatingLocation()
            break
        case .denied:
            let alertController = UIAlertController(
                title: "定位權限未開啟",
                message: "如需要變更權限，請至 設定＞隱私權＞定位服務 開啟。若無則無法提供定位資訊。",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default, handler: {(
                action: UIAlertAction!) -> Void in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let currentLocaltion = locations[0] as CLLocation
        let showMapLocation = CLLocationCoordinate2D(latitude: currentLocaltion.coordinate.latitude, longitude: currentLocaltion.coordinate.longitude)
        let _span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        dietMapView.setRegion(MKCoordinateRegion(center: showMapLocation,span: _span), animated: true)
    }
    
    func syncData() {
        fetchData{ (done) in
            if done {
                //print("Data is ready to be used in table view!")
                if(storeArray.count>0){
                    dietMapView.removeAnnotations(dietMapView.annotations)
                    for store in storeArray{
                        let ct = CLLocation(latitude: store.latitude, longitude: store.longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: ct.coordinate.latitude, longitude: ct.coordinate.longitude)
                        if let phone = store.phone {
                            annotation.subtitle = phone
                        }
                        annotation.title = store.name!
                        self.dietMapView.addAnnotation(annotation);
                    }
                    
                }else{
                    
                }
            }
        }
    }

    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let string = view.annotation!.title!!

        
        guard let managedContext  = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
        
        request.predicate = NSPredicate.init(format: "name like[c] %@", "*"+string+"*")
        do{
            var stores = try managedContext.fetch(request) as! [Store]
            if(stores.count>0){
                selectStore = stores[0];
                self.performSegue(withIdentifier: "ShowStore", sender: self)
            }
        }
        catch{
            print("Can't fetch data: ", error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStore", let StoreDetail = segue.destination as? StoreDetailViewController {
            StoreDetail.selectStore = selectStore
        }
    }
}


