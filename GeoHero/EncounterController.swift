//
//  EncounterController.swift
//  GeoHero
//
//  Created by Theodore Cross on 10/13/19.
//  Copyright © 2019 tedTosterone Enterprise. All rights reserved.
//

import UIKit

class EncounterController: UIViewController {
    
    var selectedVectorTitle : String?
    var entityType : String?;
    var input : String? = "";
    var playerHealth : Int = 50;
    var playerDamage : Int = 0;
    var monsterHealth : Int = 50;
    var monsterDamage : Int = 0;
    
    @IBOutlet weak var encounterLabel: UILabel!
    @IBOutlet weak var encounterInput: UITextField!
    
    struct Entity : Decodable {
        let EntityID : Int
        let EntityName : String
        let EntityTypeID : Int
        var EntityTypeName : String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findEntityType();
        setupForm();
        
    }
    
    @IBAction func encounterButton(_ sender: UIButton) {
        
        if encounterInput.text != "", let ei = encounterInput.text {
            input = ei;
            newLine(newLineString: "You said " + ei)
            
            if let et = entityType, let svt = selectedVectorTitle {
                
                if et == "Monsters" {
                    displayHealth()
                    if input == "hit" {
                        playerTurn()
                        monsterTurn()
                    } else if input == "run away" {
                        let escapeChance = Int.random(in: 0 ..< 10)
                        if (escapeChance > 6){
                            newLine(newLineString: "You escaped!")
                        } else {
                            newLine(newLineString: "Failed to escape monster.")
                        }
                    } else if input == "a spell" {// for loop of available spells in equipment
                        //for each spell, does match?
                    } else if input != "" {
                        newLine(newLineString: "No recognized spell.")
                        helpDialog()
                    }
                } else if et == "Items" {
                    //Options
                    if (input == "yes"){
                        newLine(newLineString: svt + " added to equipment")
                    } else if (input == "no") {
                        newLine(newLineString: "Fine, then.")
                    } else if (input != "") {
                        helpDialog();
                    }
                } else if et == "Stores" {
                    
                } else {
                    //unknown type
                }
            }
        }
        encounterInput.text = "";
    }
    
    func monsterTurn () {
        if (monsterHealth > 0) {
            let md = Int.random(in: 0 ..< 50);
            monsterDamage = md;
            newLine(newLineString: String(monsterDamage) + "DAMAGE!")
            playerHealth = playerHealth - monsterDamage;
            displayHealth();
        } else {
            newLine(newLineString: "Monster dead, you WON!")
            monsterHealth = 50;
            playerHealth = 50;
        }
        
    }
    
    func playerTurn() {
        if (playerHealth > 0) {
            let pd = Int.random(in: 0 ..< 50);
            playerDamage = pd;
            newLine(newLineString: String(playerDamage) + "DAMAGE!")
            monsterHealth = monsterHealth - playerDamage;
            displayHealth();
        } else {
            newLine(newLineString: "You are dead.")
            playerHealth = 50;
            monsterHealth = 50;
        }
    }
    
    func displayHealth () {
        newLine(newLineString: "Player health is " + String(playerHealth))
        newLine(newLineString: "Monster health is " + String(monsterHealth))
    }
    
    func setupEncounterType(){
        if let et = entityType, let svt = selectedVectorTitle {
            //say first encounters help dialog for user
            encounterLabel.text = "You encountered the " + svt + " a/an " + et;
            
            if et == "Monsters" {
                newLine(newLineString: "Type hit to attack with might.")
                newLine(newLineString: "Or type the name of the spell you'd like to use.")
                newLine(newLineString: "Or type run away, like a pussy.")
            } else if et == "Items" {
                newLine(newLineString: "Wanna pick it up? Type yes or no.")
            } else if et == "Stores" {
                newLine(newLineString: "Type buy or sell.")
            } else {
                //unknown type
            }
        } else {
            encounterLabel.text = "We done fucked up something."
        }
    }
    
    func helpDialog () {
        newLine(newLineString: "The fuck you mean?")
        newLine(newLineString: "Type Exit to leave encounter, or swipe the window down to leave.")
    }
    
    func newLine(newLineString : String?) {
        if let nl = newLineString, let el = encounterLabel.text {
            
            encounterLabel.text = "\(el) \n \(nl)"
        }
    }
    
    func setupForm() {
        encounterLabel.numberOfLines = 0
        setupEncounterType();
    }
    
    func findEntityType() {
        //Mock Conditions
        var availableEnts : [Entity] = [Entity]();
        
        //Mock Data
        availableEnts = [Entity(EntityID: 6, EntityName: "Bow", EntityTypeID: 2, EntityTypeName: "Items"), Entity(EntityID: 14, EntityName: "Potion", EntityTypeID: 2, EntityTypeName: "Items"), Entity(EntityID: 5, EntityName: "Staff", EntityTypeID: 2, EntityTypeName: "Items"), Entity(EntityID: 4, EntityName: "Sword", EntityTypeID: 2, EntityTypeName: "Items"), Entity(EntityID: 1, EntityName: "Dragon", EntityTypeID: 1, EntityTypeName: "Monsters"), Entity(EntityID: 2, EntityName: "Goblin", EntityTypeID: 1, EntityTypeName: "Monsters"), Entity(EntityID: 13, EntityName: "Greg the Ogre", EntityTypeID: 1, EntityTypeName: "Monsters"), Entity(EntityID: 15, EntityName: "Jobi the Meatsack", EntityTypeID: 1, EntityTypeName: "Monsters"), Entity(EntityID: 3, EntityName: "Skeleton", EntityTypeID: 1, EntityTypeName: "Monsters"), Entity(EntityID: 7, EntityName: "General Store", EntityTypeID: 3, EntityTypeName: "Stores")]
        
        for ent in availableEnts {
            if (ent.EntityName == selectedVectorTitle) {
                entityType = ent.EntityTypeName;
                print("found the type", ent.EntityTypeName, "for", ent.EntityName)
                break;
            } else {
                print("didnt find shit for types")
            }
        }
        
    }
    
}
