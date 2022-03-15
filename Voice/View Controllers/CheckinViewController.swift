//
//  CheckinViewController.swift
//  Voice
//
//  Created by Minoo Kim on 11/25/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChecklistItem {
    var dir: String
    var isChecked: Bool = false
    init(dir: String){
        self.dir = dir
    }
}

class CheckinViewController: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SaveButton: UIButton!
    
    //var data = [String]()
    var data: [ChecklistItem] = []

    // making firstore synchronous basically
    var didFinishLoading = false {
        didSet {
            self.TableView.reloadData()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // connect to firestore
        getData()
        // setup table
        TableView.delegate = self
        TableView.dataSource = self
        self.TableView.allowsMultipleSelection = true
        
    }
    func getData(){
        let db = Firestore.firestore()
        db.collection("medical").whereField("nurseUID", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else{
                for document in querySnapshot!.documents {
                    let amount = document["amount"]  as! String
                    let medicine = document["medicine"]  as! String
                    let patient = document["patient"]  as! String
                    let time = document["time"] as! String
                    let res = "Give " + amount +  " of " + medicine + " to " +  patient + " at " + time
                    if(document["completed"] as! Bool == false){
                        self.data.append(ChecklistItem(dir: res))
                    }
                }
                self.didFinishLoading = true
            }
        }
    }
    @IBAction func SaveTapped(_ sender: Any) {
        // obtaining indexpaths of only checkmarked tasks
        var selected_indexPaths : [IndexPath] = []
        for indexPath in TableView.indexPathsForVisibleRows! {
            let cell = tableView(TableView, cellForRowAt: indexPath) as! CheckInTableViewCell
            if(cell.accessoryType == .checkmark){
                selected_indexPaths.append(indexPath)
            }
        }
        
        // get medical directions
        var values : [String] = []
        for indexPath in selected_indexPaths {
            let cell = tableView(TableView, cellForRowAt: indexPath) as! CheckInTableViewCell
            values.append(cell.TextView.text!)
        }
        
        // connect to firebase to resolve task
        for val in values{
            let sentence = val.components(separatedBy: " ")
            let count = sentence.count
            let time = sentence[count-6] + " " + sentence[count-5] + " " +  sentence[count-4] + " " +  sentence[count-3] + " " +  sentence[count-2] + " " + sentence[count-1];
            print(time);
            let db = Firestore.firestore()
            // potentially add more whereField conditions (time, date, etc) here to guarantee correct match
            db.collection("medical").whereField("nurseUID", isEqualTo: Auth.auth().currentUser!.uid).whereField("time", isEqualTo: time)
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        let docID = document.documentID;
                        // change completed field to true
                        print("computer has reached this code");
                        db.collection("medical").document(docID).updateData(["completed" : true]);
                    }
                }
            }
        }
        transitionToNurse()
    }
}

extension CheckinViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of tasks for nurse
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckInTableViewCell
        cell.TextView.text! = item.dir
        cell.accessoryType = item.isChecked ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        item.isChecked = !item.isChecked
        self.TableView.reloadData()
    }
     
    func transitionToNurse(){
        let nurseViewCOntroller =
        storyboard?.instantiateViewController(withIdentifier:
            Constants.Storyboard.nurseViewController) as?
            NurseViewController
        view.window?.rootViewController = nurseViewCOntroller
        view.window?.makeKeyAndVisible()
    }
}
