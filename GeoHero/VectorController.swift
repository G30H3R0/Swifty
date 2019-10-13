//
//  VectorController.swift
//  GeoHero
//
//  Created by Theodore Cross on 9/2/19.
//  Copyright © 2019 tedTosterone Enterprise. All rights reserved.
//

import UIKit;
import CoreLocation;
import MapKit;

struct Entity : Decodable {
    let EntityID : Int
    let EntityName : String
    let EntityTypeID : Int
    var EntityTypeName : String
}

struct Return : Decodable {
    let CRUD : String
}

class VectorController: UIViewController {
    
    let locationManager = CLLocationManager();
    
    @IBOutlet weak var currentLocationLabel: UILabel!;
    @IBOutlet weak var headerLabel: UILabel!;
    
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var options : [String] = [String]();
    var ents : [Entity] = [Entity]();
    var selectedType :String?;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        createLabels();
        createPicker();
        returnEntities();
    }
    
    func createPicker(){
        let typePicker = UIPickerView()
        typePicker.delegate = self;
        typePicker.dataSource = self;
        typeTextField.inputView = typePicker;
        fetchEntities();
    }
    
    func createLabels(){
        guard let long = locationManager.location?.coordinate.longitude, let lat = locationManager.location?.coordinate.latitude else { return };
        headerLabel.text = "Add the following under my current coordinates.";
        currentLocationLabel.text = "LONG: \(long) LAT: \(lat)";
    }
    
    @IBAction func backtoView(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    func fetchEntities() {
        let url = URL(string: "http://165.22.136.184:5000/coordinates/entityDetail/");
        var arr = [String]();
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                let ents = try JSONDecoder().decode([Entity].self, from: data)
                
                for ent in ents {
                    let str = ent.EntityTypeName + ": " + ent.EntityName;
                    arr.append(str);
                }
                arr.insert("New Quest", at: 0)
                self.populatePicker(arr: arr);
            } catch let JSONerror {
                print ("error parsing JSON", JSONerror)
            }
        }.resume()
    }
    
    func returnEntities () {
        let url = URL(string: "http://165.22.136.184:5000/coordinates/entityDetail/");
        var array: [Entity] = [Entity]();
        
         URLSession.shared.dataTask(with: url!) { (data, response, err) in
             guard let data = data else { return }
             
             do {
                 array = try JSONDecoder().decode([Entity].self, from: data)
                
                self.populateEnts(array:array);
             } catch let JSONerror {
                 print ("error parsing JSON", JSONerror)
             }
         }.resume()
    }
    
    func populateEnts(array : [Entity] ) {
        ents = array;
        print("ents in populate ents", ents);
    }
    
    func populatePicker(arr: [String]) {
        print("populate picker");
        options = arr;
    }
    
    @IBAction func addVector(_ sender: Any) {
        if options.count != 0 && selectedType != nil {
            print("thar she blows", selectedType!);
            if selectedType! == "New Quest" {
                print("segue to Edit Quests")
            }
            else {
                print("add coordinate to database", selectedType!);
                
                var entID:Int = 0;
                
                let str = selectedType!.trimmingCharacters(in: .whitespacesAndNewlines)
                let index = str.index(of: ":")!
                let type = str.prefix(upTo: index)
                let name = str.suffix(from: index).dropFirst().dropFirst();
                
                print(type)
                print(name)
                
                for ent in ents {
                    print(type, name, ent);
                    if (ent.EntityTypeName == type && ent.EntityName == name){
                        entID = ent.EntityID
                        break;
                    }
                }
                
                //match name and get entityID
                if (entID == 0){
                    print ("we havnt found shit")
                }
                else {
                    //put route
                    print("success")
                    
                    guard let long = locationManager.location?.coordinate.longitude, let lat = locationManager.location?.coordinate.latitude else { return };
                    headerLabel.text = "Add the following under my current coordinates.";
                    currentLocationLabel.text = "LONG: \(long) LAT: \(lat)";
                    
                    let url = URL(string: "http://165.22.136.184:5000/CRUD/coordinate/C/null/\(long)/\(lat)/\(entID)");
                    var array : [Return] = [Return]();
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, err) in
                        guard let data = data else { return }
                        
                        do {
                            array = try JSONDecoder().decode([Return].self, from: data)
                           
                            print("created?", array)
                        } catch let JSONerror {
                            print ("error parsing JSON", JSONerror)
                        }
                    }.resume()
                    
                     performSegue(withIdentifier: "reloadVectors", sender: nil)
                }
            }
        }
        else {
            print("its goddamn empty")
        }
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVectorSegue"{
            let nextVC = segue.destination as! VectorController;
        }
        else if segue.identifier == "reloadVectors" {
            let nextVC = segue.destination as! ViewController;
        }
    }
}

extension VectorController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in typePicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ typePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ typePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = options[row];
        typeTextField.text = selectedType
        view.endEditing(true);
    }
    
}




