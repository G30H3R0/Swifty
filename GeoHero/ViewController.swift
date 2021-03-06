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
    var userLongitude : Double?;
    var userLatitude : Double?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        setupMapView()
    }
    
    @IBAction func addVector(_ sender: Any) {
        performSegue(withIdentifier: "addVectorSegue", sender: nil)
    }
    
    func setupMapView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector(("triggerTouchAction")))
        mapView.addGestureRecognizer(tapRecognizer)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, span: MKCoordinateSpanMake(0.1, 0.1)) //sets a lock mechanism of scrolling out too much will eventually center back
            mapView.setRegion(region, animated: true )
        }
    }
    
    func checkLocationAuthorization () {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse , .authorizedAlways:
            //While using the app
            mapView.showsUserLocation = true
            getCurrentCoordinates()
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
    
    func getCurrentCoordinates () {
        guard let long = locationManager.location?.coordinate.longitude
            , let lat = locationManager.location?.coordinate.latitude else { return };
        
        userLongitude = long;
        userLatitude = lat;
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
        
        var pinImage = UIImage(named: "")
        var size = CGSize(width: 50, height: 50)
       
        print(annotation.subtitle)
        
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
            pinImage = UIImage(named: "quest.jpg")
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
        pinImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        annotationView.image = resizedImage
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoDark)
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func completeVectorsFetch (array: [Vector]) {
        vectors = array;
        populateVectors();
        print ("vectors", vectors)
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
        //connect to server here and get close entities
        self.getMockCoordinates()
    }
    
    func getMockCoordinates () {
        //Display error message
//        let alert = UIAlertController(title: "Cant connect to server.", message: "Using mock data instead.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cant connect to server, using mock data.", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated:true)
        
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
        if let long = userLongitude, let lat = userLatitude {
            for vector in vectors {
                //spread coordinates from current location
                let newLat = lat + Double.random(in: -50 ..< 50) * 0.00001;
                let newLong = long + Double.random(in: -50 ..< 50) * 0.00001;
                
                newVectors.append(Vector(CoordinateID: vector.CoordinateID, EntityID: vector.EntityID, EntityName: vector.EntityName, EntityTypeName: vector.EntityTypeName, Longitude: newLong, Latitude:  newLat))
            }
        }
        
        self.completeVectorsFetch(array: newVectors);
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == view.rightCalloutAccessoryView {
            if let vectorTitle = view.annotation?.title! {
                selectedVector = vectorTitle;
                performSegue(withIdentifier: "encounterVector", sender: nil)
            }
        }
    }
    
    @IBAction func triggerTouchAction() {
        print("tapped map" )
    }
    
    
    @objc func addAnnotation(longGesture: UIGestureRecognizer) {

        if longGesture.state == UIGestureRecognizerState.ended { //longpress ended
            let touchPoint = longGesture.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    
            print ("lat", location.latitude)
            print ("long", location.longitude)
            
            //add random vector for now
                //need to add functionaliy to display to the user which entity type to use
                //and what entity name to use
            
            let mock = [
                GeoHero.Vector(CoordinateID: 28, EntityID: 1, EntityName: "Dragon", EntityTypeName: "Monsters", Longitude: -93.263488, Latitude: 44.981995)
                , GeoHero.Vector(CoordinateID: 34, EntityID: 2, EntityName: "Goblin", EntityTypeName: "Monsters", Longitude: -93.263506, Latitude: 44.981995)
                , GeoHero.Vector(CoordinateID: 31, EntityID: 4, EntityName: "Sword", EntityTypeName: "Items", Longitude: -93.263282, Latitude: 44.981873)
                , GeoHero.Vector(CoordinateID: 32, EntityID: 5, EntityName: "Staff", EntityTypeName: "Items", Longitude: -93.263426, Latitude: 44.981995)
                , GeoHero.Vector(CoordinateID: 33, EntityID: 6, EntityName: "Bow", EntityTypeName: "Items", Longitude: -93.263493, Latitude: 44.981995)
                , GeoHero.Vector(CoordinateID: 35, EntityID: 7, EntityName: "General Store", EntityTypeName: "Stores", Longitude: -93.263462, Latitude: 44.981964)
                , GeoHero.Vector(CoordinateID: 29, EntityID: 13, EntityName: "Greg the Ogre", EntityTypeName: "Monsters", Longitude: -93.263521, Latitude: 44.981934)
            ]
            
            if let randomVector = mock.randomElement() {
                //add new vector to database
                
                //for now add random coordinate with 0 CoordinateID
                vectors.append(Vector(CoordinateID: 0, EntityID: randomVector.EntityID , EntityName: randomVector.EntityName, EntityTypeName: randomVector.EntityTypeName, Longitude: location.longitude, Latitude:  location.latitude))
                print(randomVector.EntityName, "added!")
                print("added new vectors", vectors)
                
                var newArray = [Vector]();
                newArray.append(Vector(CoordinateID: 0, EntityID: randomVector.EntityID , EntityName: randomVector.EntityName, EntityTypeName: randomVector.EntityTypeName, Longitude: location.longitude, Latitude:  location.latitude))
                self.completeVectorsFetch(array: newArray)
                
            } else {
                print ("what the hell vectors is empty?")
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpanMake(0.001, 0.001)) //sets default region and locks it
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
    }
}
