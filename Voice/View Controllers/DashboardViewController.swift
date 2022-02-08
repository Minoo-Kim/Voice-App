//
//  DashboardViewController.swift
//  Voice
//
//  Created by Minoo Kim on 2/7/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class DashboardViewController: UIViewController {

    @IBOutlet weak var DashView: UITableView!
    var data = [String]()
    var done = [String]()
    // making firstore synchronous basically
    var didFinishLoading = false {
        didSet {
            self.DashView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // connect to firestore
        getData()
        // setup table
        DashView.delegate = self
        DashView.dataSource = self
        self.DashView.allowsMultipleSelection = true
    }
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("medical").getDocuments() { (querySnapshot, err) in
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
                    if(document["completed"] as! Bool){
                        self.done.append("Completed: " + res);
                    }
                    else {
                        self.data.append("Needs action: " + res);
                    }
                }
                // in order to vizualize priority
                for sent in self.done{
                    self.data.append(sent);
                }
                self.didFinishLoading = true
            }
        }
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of tasks for nurse
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashCell", for: indexPath) as! DashboardTableViewCell
        cell.DashText.text! = data[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
