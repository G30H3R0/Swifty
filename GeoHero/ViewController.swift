//
//  ViewController.swift
//  GeoHero
//
//  Created by Theodore Cross on 7/22/19.
//  Copyright © 2019 tedTosterone Enterprise. All rights reserved.
//

import UIKit;
import CoreLocation;
import MapKit;

struct Vector : Decodable {
    let CoordinateID : Int
    let EntityID : Int
    let EntityName : String
    let EntityTypeName : String
    let Longitude : Double
    let Latitude : Double
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager();
    let regionInMeters: Double = 10000;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
    }
    
    @IBAction func addVector(_ sender: Any) {
        performSegue(withIdentifier: "addVectorSegue", sender: nil)
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, span: MKCoordinateSpanMake(0.001, 0.001))
            mapView.setRegion(region, animated: true )
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            //While using the app
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            getNearEntities()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            //Show user how to enable location services
            break
        case .notDetermined:
            //ask permission
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //parental controls
            break
        case .authorizedAlways:
            //run in background
            break
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print ("User enable location services");
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self as CLLocationManagerDelegate;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getNearEntities(){
        guard let long = locationManager.location?.coordinate.longitude, let lat = locationManager.location?.coordinate.latitude else { return }
        guard let url = URL(string: "http://165.22.136.184:5000/coordinates/entitiesClose/\(long)/\(lat)") else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let error = err {
                print ("Error occured, now using Mock data.", error)
                //Mock Data with current coordinates
                let vectors = [GeoHero.Vector(CoordinateID: 28, EntityID: 1, EntityName: "Dragon", EntityTypeName: "Monsters", Longitude: -93.263488, Latitude: 44.981995), GeoHero.Vector(CoordinateID: 34, EntityID: 2, EntityName: "Goblin", EntityTypeName: "Monsters", Longitude: -93.263506, Latitude: 44.981995), GeoHero.Vector(CoordinateID: 31, EntityID: 4, EntityName: "Sword", EntityTypeName: "Items", Longitude: -93.263282, Latitude: 44.981873), GeoHero.Vector(CoordinateID: 32, EntityID: 5, EntityName: "Staff", EntityTypeName: "Items", Longitude: -93.263426, Latitude: 44.981995), GeoHero.Vector(CoordinateID: 33, EntityID: 6, EntityName: "Bow", EntityTypeName: "Items", Longitude: -93.263493, Latitude: 44.981995), GeoHero.Vector(CoordinateID: 35, EntityID: 7, EntityName: "General Store", EntityTypeName: "Stores", Longitude: -93.263462, Latitude: 44.981964), GeoHero.Vector(CoordinateID: 29, EntityID: 13, EntityName: "Greg the Ogre", EntityTypeName: "Monsters", Longitude: -93.263521, Latitude: 44.981934)]
                
                
                for vector in vectors {
                    //spread coordinates
                    let randomLat = Double.random(in: 0 ..< 30) * 0.00001;
                    let randomLong = Double.random(in: 0 ..< 30) * 0.00001;
                    print ("random decimal", randomLat, randomLong);
                    
                    print(vector);
                    //add vector to map
                    let newVector = MKPointAnnotation();
                    newVector.title = vector.EntityName
                    newVector.subtitle = vector.EntityTypeName
                    newVector.coordinate = CLLocationCoordinate2D(latitude: lat + randomLat, longitude: long + randomLong)
                    self.mapView.addAnnotation(newVector)
                }
            } else {
                guard let data = data else { return }
                
                do {
                    let vectors = try JSONDecoder().decode([Vector].self, from: data)
                    
                    print ("vectors", vectors)
                    
                    for vector in vectors {
                        print(vector);
                        let newVector = MKPointAnnotation();
                        newVector.title = vector.EntityName
                        newVector.subtitle = vector.EntityTypeName
                        newVector.coordinate = CLLocationCoordinate2D(latitude: vector.Latitude, longitude: vector.Longitude)
                        self.mapView.addAnnotation(newVector)
                    }
                } catch let JSONerror {
                    print ("error parsing JSON entities", JSONerror)
                }
            }
        }.resume()
    }
    

    
}

extension ViewController: CLLocationManagerDelegate {
    
    //As user moves
    func locationManaer(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpanMake(0.001, 0.001))
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
    }
}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        print ("tapped on a pin");
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let vectorTitle = view.annotation?.title! {
                performSegue(withIdentifier: "encounterVector", sender: nil)
                print (vectorTitle);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVectorSegue"{
            _ = segue.destination as! VectorController;
        } else if segue.identifier == "encounterVector"{
            _ = segue.destination as! EncounterController;
        }
    }
}







