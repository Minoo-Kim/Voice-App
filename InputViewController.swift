//
//  InputViewController.swift
//  Voice
//
//  Created by Minoo Kim on 11/21/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class InputViewController: UIViewController {

    @IBOutlet weak var voiceinput: UIButton!
    @IBOutlet weak var patient: UITextField!
    @IBOutlet weak var medicine: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var nurse: UITextField!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // nurse picker list setup
    var nurseList: Array<String> = []
    var pickerView = UIPickerView()
    // date picker setup
    let datePicker = UIDatePicker()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        nurse.inputView = pickerView
    }
    
    func validateFields()->String?{
        // Check that all fields are filled in
        if patient.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            medicine.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            amount.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            nurse.text == "" {
            // add date and time values
            return "Please fill in all fields."
        }
        return nil
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // Validate the fields
        let error = validateFields()
        if error != nil {
            showError(message:error!)
        }
        else{
            // Store cleaned versions of the data
            let patientText = patient.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let medicineText = medicine.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountText = amount.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let nurseText = nurse.text
            let first = nurseText?.components(separatedBy: " ")[0]
            let last = nurseText?.components(separatedBy: " ")[1]
            let timeText =  time.text
            // get nurseUID to reference on nurse backend
            let db = Firestore.firestore()
            db.collection("users").whereField("firstname", isEqualTo: first!).whereField("lastname", isEqualTo: last!)
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        print(document["uid"]!)
                        let nurseUID = document["uid"] as! String
                        // Send data to firebase; set doc ID as assigned nurse to easily access from nurse's side of view
                        db.collection("medical").addDocument(data: ["patient":patientText,
                                                                    "medicine":medicineText,
                                                                    "amount": amountText,
                                                                    "nurse":nurseText!,
                                                                    "nurseUID":nurseUID,
                                                                    "time":timeText!,
                                                                    "completed":false]) {(error) in
                                    if error != nil {
                                        // Show error message
                                        self.showError(message:"Error saving user data")
                                    }
                                }
                    }
                }
            }
            
            // Transition to home screen
            self.transitionToDoctor()
            }
        }
        
    
    func setUpElements(){
        // Hide error label
        errorLabel.alpha=0;
        
        // setup non-picker elements
        Utilities.styleTextField(patient)
        Utilities.styleTextField(medicine)
        Utilities.styleTextField(amount)
        Utilities.styleFilledButton(done)
        
        // set up nurse picker via firestore database
        let db = Firestore.firestore()
        db.collection("users").whereField("Doctor", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        let firstname: String = document["firstname"] as! String
                        let lastname: String = document["lastname"] as! String
                        let name: String = firstname+" "+lastname
                        self.nurseList.append(name)
                    }
                }
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        createDatePicker()
    }
 
    func showError( message:String){
        errorLabel.text=message
        errorLabel.alpha=1
    }
    // need to make transition back to menu
    func transitionToDoctor(){
        let doctorViewController =
        storyboard?.instantiateViewController(withIdentifier:
            Constants.Storyboard.doctorViewController) as?
            DoctorViewController
        view.window?.rootViewController = doctorViewController
        view.window?.makeKeyAndVisible()
    }
    func createDatePicker(){
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated:true)
        // assign toolbar
        time.inputAccessoryView = toolbar
        // assign date picker to the text field
        time.inputView  = datePicker
        // date picker mode
        datePicker.datePickerMode = .dateAndTime
    }
    @objc func  donePressed(){
        // formatter
        let formatter =  DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        time.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

}

// for nurse picker
extension InputViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nurseList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nurseList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nurse.text=nurseList[row]
        nurse.resignFirstResponder()
    }
}
