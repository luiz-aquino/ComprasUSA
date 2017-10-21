//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 13/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add, edit
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let tableCellIdentifier = "stateCell"
    var fetchedResultController: NSFetchedResultsController<State>!
    var label: UILabel!
    var state: State!
    var alert: UIAlertController!
    
    @IBOutlet weak var tfDollar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.register(StateItemTableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        
        loadStates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tfDollar.text = String(format : "%.2f" ,UserDefaults.standard.double(forKey: "dollar"))
        tfIOF.text = String(format: "%.2f", UserDefaults.standard.double(forKey: "iof"))
    }
    
    @IBAction func dollarChanged(_ sender: UITextField) {
        if let value = tfDollar.text, let dValue = Double(value), dValue > 0 {
            UserDefaults.standard.set(dValue, forKey: "dollar")
        }
    }
    
    @IBAction func iofChanged(_ sender: UITextField) {
        if let value = tfIOF.text, let dValue = Double(value), dValue >= 0 {
            UserDefaults.standard.set(dValue, forKey: "iof")
        }
    }
    
    func loadStates() {
        let fetchedRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateTextChange(sender: UITextField)
    {
        var allValid = true
        
        if let fields = alert.textFields {
            for field in fields {
                if let placeHolder = field.placeholder {
                    if placeHolder.range(of: "Nome") != nil {
                        
                        if let text = field.text, text.count > 1 {
                        
                            allValid = allValid && true
                        
                        } else {
                            
                            allValid = false
                        
                        }
                    } else if placeHolder.range(of: "Imposto") != nil {
                        
                        if let text = field.text, let dValue = Double(text), dValue >= 0.0 {
                            
                            allValid = allValid && true
                        
                        } else {
                         
                            allValid = false
                        
                        }
                    }
                }
            }
        }
        
        if let okButton = alert.actions.first {
            okButton.isEnabled = allValid
        }
    }
    
    func showDialog(type: CategoryType, state: State? )
    {
        let title = (type == .add) ? "Adicionar" : "Editar"
        alert = UIAlertController(title: "\(title) estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            if let name = state?.name {
                textField.text = name
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = String(format: "%.2f", tax)
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = self.state ?? State(context: self.context)
            var errorMessage = ""
            if let name = self.alert.textFields?.first?.text, name.count > 0 {
                state.name = name
            }
            else {
                errorMessage += "Sem nome \n"
            }
            
            if let strTax = self.alert.textFields?.last?.text, let tax = Double(strTax) {
                state.tax = tax
            }
            else {
                errorMessage += "Sem Taxa"
            }
            
            if errorMessage.count > 1 {
                print(errorMessage)
                self.context.delete(state)
                self.state = nil
            }
            
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        if let firstAction = alert.actions.first {
            firstAction.isEnabled = false
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: UIButton) {
        showDialog(type: .add, state: nil)
    }
    
}

extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("change")
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.fetchedResultController.object(at: indexPath)
        tableView.setEditing(false, animated: true)
        self.showDialog(type: .edit, state: state)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.fetchedResultController.object(at: indexPath)
            self.context.delete(state)
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }
        
//        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
//            let state = self.fetchedResultController.object(at: indexPath)
//            tableView.setEditing(false, animated: true)
//            self.showDialog(type: .edit, state: state)
//        }
//        editAction.backgroundColor = .blue
        return [deleteAction]
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StateItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! StateItemTableViewCell
        
        let state = fetchedResultController.object(at: indexPath)
        
        if let name = state.name {
            cell.lbName.text = name
        }
        
        cell.lbPrice.text = String(format: "%.2F", state.tax)
        
        return cell
    }
}
