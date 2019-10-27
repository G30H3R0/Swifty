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
    var Longitude : Double
    var Latitude : Double
}

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager();
    let regionInMeters: Double = 10000;
    var selectedVector: String = "Intialized";
    var vectors : [Vector] = [Vector]();
    
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
        case .authorizedWhenInUse , .authorizedAlways:
            //While using the app
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            fetchNearEntities()
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom pin")
        
        var pinImage = UIImage(named: "myLocation.png")
        var size = CGSize(width: 50, height: 50)
       
        switch annotation.subtitle {
        case "Monsters":
            pinImage = UIImage(named: "monsterClaw.png")
            break
        case "Items":
            pinImage = UIImage(named: "sword.png")
            size = CGSize(width: 60, height: 60)
            break
        case "Stores":
            pinImage = UIImage(named: "store.png")
            break
        case "Quests":
            pinImage = UIImage(named: "quest.png")
            break
        default:
            pinImage = UIImage(named: "redPin.png")
            size = CGSize(width: 40, height: 70)
            break
        }
        
        if (annotation.title == "My Location"){
            pinImage = UIImage(named: "myLocation.png")
            size = CGSize(width: 40, height: 70)
        }
        
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        annotationView.image = resizedImage
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoDark)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func completeVectorsFetch (array: [Vector]) {
        vectors = array;
        populateVectors();
    }
    
    func populateVectors () {
        for vector in vectors {
            let vec = CLLocationCoordinate2DMake(vector.Latitude, vector.Longitude)
            let pin = CustomAnnotation(coor: vec)
            pin.title = vector.EntityName
            pin.subtitle = vector.EntityTypeName
            self.mapView.addAnnotation(pin)
        }
    }
    
    func fetchNearEntities(){
        guard let long = locationManager.location?.coordinate.longitude, let lat = locationManager.location?.coordinate.latitude else { return }
        guard let url = URL(string: "http://165.22.136.184:5000/coordinates/entitiesClose/\(long)/\(lat)") else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let error = err {
                print ("Error occured, now using Mock data.", error)
                //Mock Data with current coordinates
                let vectors = [
                    GeoHero.Vector(CoordinateID: 28, EntityID: 1, EntityName: "Dragon", EntityTypeName: "Monsters", Longitude: -93.263488, Latitude: 44.981995)
                    , GeoHero.Vector(CoordinateID: 34, EntityID: 2, EntityName: "Goblin", EntityTypeName: "Monsters", Longitude: -93.263506, Latitude: 44.981995)
                    , GeoHero.Vector(CoordinateID: 31, EntityID: 4, EntityName: "Sword", EntityTypeName: "Items", Longitude: -93.263282, Latitude: 44.981873)
                    , GeoHero.Vector(CoordinateID: 32, EntityID: 5, EntityName: "Staff", EntityTypeName: "Items", Longitude: -93.263426, Latitude: 44.981995)
                    , GeoHero.Vector(CoordinateID: 33, EntityID: 6, EntityName: "Bow", EntityTypeName: "Items", Longitude: -93.263493, Latitude: 44.981995)
                    , GeoHero.Vector(CoordinateID: 35, EntityID: 7, EntityName: "General Store", EntityTypeName: "Stores", Longitude: -93.263462, Latitude: 44.981964)
                    , GeoHero.Vector(CoordinateID: 29, EntityID: 13, EntityName: "Greg the Ogre", EntityTypeName: "Monsters", Longitude: -93.263521, Latitude: 44.981934)
                ]
                
                //Cant change vectors array, create new one and mutate
                var newVectors = [Vector]();
                
                for vector in vectors {
                    //spread coordinates from current location
                    let newLat = vector.Latitude + Double.random(in: -50 ..< 50) * 0.00001;
                    let newLong = vector.Longitude + Double.random(in: -50 ..< 50) * 0.00001;
                    
                    newVectors.append(Vector(CoordinateID: vector.CoordinateID, EntityID: vector.EntityID, EntityName: vector.EntityName, EntityTypeName: vector.EntityTypeName, Longitude: newLong, Latitude:  newLat))
                }
                
                self.completeVectorsFetch(array: newVectors);
                
            } else {
                guard let data = data else { return }
                
                do {
                    let vectors = try JSONDecoder().decode([Vector].self, from: data)
                    
                    self.completeVectorsFetch(array: vectors)
                } catch let JSONerror {
                    print ("error parsing JSON entities", JSONerror)
                }
            }
        }.resume()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("tap!")
        if control == view.rightCalloutAccessoryView {
            if let vectorTitle = view.annotation?.title! {
                selectedVector = vectorTitle;
                performSegue(withIdentifier: "encounterVector", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVectorSegue"{
            _ = segue.destination as! VectorController;
        } else if segue.identifier == "encounterVector"{
            _ = segue.destination as! EncounterController;
            
            //print("selected vector", selectedVector)
            let destinationVC = segue.destination as! EncounterController
            destinationVC.selectedVectorTitle = selectedVector;
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    //As user moves
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpanMake(0.001, 0.001))
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
    }
}








