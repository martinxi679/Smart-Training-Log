//
//  TreatmentsViewController.swift
//  Smart Training Log
//

import UIKit
import Firebase
import FirebaseDatabase

class TreatmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treatmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        
        let treatment: DummyTreatment
        
        treatment = treatmentList[indexPath.row]
        
        cell.titleLabel.text = treatment.title
        
        return cell
    }
    
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTreatmentButton: UIButton!
    
    var treatmentList = [DummyTreatment]()
    override func viewDidLoad() {
        ref = Database.database().reference().child("treatments");
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.treatmentList.removeAll()
                for treatments in snapshot.children.allObjects as! [DataSnapshot] {
                    let treatmentObject = treatments.value as? [String: AnyObject]
                    let uid = treatmentObject?["uid"]
                    let title = treatmentObject?["title"]
                    let content = treatmentObject?["content"]
                    
                    let treatment = DummyTreatment(with: uid as! String, title: title as! String, content: content as! String)
                    
                    self.treatmentList.append(treatment)
                }
                self.tableView.reloadData()
            }
        })
        // setup
    }
    
}
