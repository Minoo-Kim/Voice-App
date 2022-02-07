//
//  CheckinViewController.swift
//  Voice
//
//  Created by Minoo Kim on 11/25/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class CheckinViewController: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SaveButton: UIButton!
    var data = [String]()
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
                        self.data.append(res)
                    }
                }
                self.didFinishLoading = true
            }
        }
    }
    @IBAction func SaveTapped(_ sender: Any) {
        var values : [String] = []
        let selected_indexPaths = TableView.indexPathsForSelectedRows
        for indexPath in selected_indexPaths! {
            let cell = tableView(TableView, cellForRowAt: indexPath) as! CheckInTableViewCell
            values.append(cell.TextView.text!)
        }
        for val in values{
            let sentence = val.components(separatedBy: " ")
            let patient = sentence[5] + " " + sentence[6];
            print(patient);
            let db = Firestore.firestore()
            // potentially add more whereField conditions (time, date, etc) here to guarantee correct match
            db.collection("medical").whereField("nurseUID", isEqualTo: Auth.auth().currentUser!.uid).whereField("patient", isEqualTo: patient)
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        let docID = document.documentID;
                        // change completed field to true
                        print("computer has reached this code");
                        print(document["medicine"] as! String);
                        db.collection("medical").document(docID).updateData(["completed" : true]);
                    }
                }
            }
        }
        print(values);
    }
}
extension CheckinViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of tasks for nurse
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckInTableViewCell
        cell.TextView.text! = data[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    // check mark stuff but it's kinda buggy
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        if(TableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark){
//            TableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
//            TableView.deselectRow(at: indexPath, animated: true)
//        }
//        else{
//            TableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
//        }
//    }
}



