//
//  ViewController.swift
//  school
//
//  Created by Артём Коротков on 03.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var childrens: People?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var timesInSchool: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var photoLabel: UIImageView!
    
     override func viewDidLoad() {
         super.viewDidLoad()
         getDataFromFile()
         updateSC()
    
     }
    
    private func getDataFromFile() {
        
        let fetchRequest: NSFetchRequest<People> = People.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name != nil")
        
        var records = 0
        
        do {
            records = try context.count(for: fetchRequest)
            print(records)
        } catch {
            print(error)
        }
        
        guard records == 0 else { return }
        
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else {return}
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "People", in: context)
            let people = NSManagedObject(entity: entity!, insertInto: context) as! People
            
            
            let peopleDict = dict as! [String: AnyObject]
            people.name = peopleDict["name"] as? String
            people.secondName = peopleDict["secondName"] as? String
            people.age = peopleDict["age"] as! Int16
            people.timesGoToSchool = peopleDict["timesGoToSchool"] as! Int16
            
            let imageName = peopleDict["photo"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image?.pngData()
            people.photo = imageData
            
        }
    }
    
    private func insertDataFrom(selectedChildren childrens: People!) {
        nameLabel.text = childrens.name
        secondNameLabel.text = childrens.secondName
        ageLabel.text = "\(childrens.age) years old"
        timesInSchool.text = "\(childrens.timesGoToSchool) times was in school"
        photoLabel.image = UIImage(data: childrens.photo!)
    }
    
    private func updateSC() {
        let fetchRequest: NSFetchRequest<People> = People.fetchRequest()
        let name = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name!)
        do {
            let results = try context.fetch(fetchRequest)
            childrens = results.first
            insertDataFrom(selectedChildren: childrens)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    

    @IBAction func goToSchoolTapped(_ sender: UIButton) {
        childrens?.timesGoToSchool += 1
        do {
            try context.save()
            insertDataFrom(selectedChildren: childrens)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
      
    }
    
    
    @IBAction func segmentedTapped(_ sender: UISegmentedControl) {
        updateSC()
    }
}

