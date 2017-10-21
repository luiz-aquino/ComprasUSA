//
//  RegisterProductViewController.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 12/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import UIKit
import CoreData

class RegisterProductViewController: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var spCreditCard: UISwitch!
    @IBOutlet weak var btSave: UIButton!
    
    var fetchedResultController:  NSFetchedResultsController<State>!
    var pickerView: UIPickerView!
    var currentState: State!
    var product: Product!
    var smallImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelState))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputView = pickerView
        tfState.inputAccessoryView = toolbar
        
        if product != nil {
            btSave.setTitle("Salvar", for: .normal)
            tfName.text = product.name
            if let state = product.state {
                tfState.text = state.name
                currentState = state
            }
            tfPrice.text = String(format: "%.2f", product.price)
            spCreditCard.isOn = product.usedCreaditCard
            if let image = product.picture as? UIImage {
                ivImage.image = image
            }
        }
        
        loadStates();
        // Do any additional setup after loading the view.
    }

    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func cancelState() {
        tfState.resignFirstResponder()
    }
    
    func done() {
        currentState = fetchedResultController.object(at: IndexPath(row: pickerView.selectedRow(inComponent: 0), section: 0))
        tfState.text = currentState.name
        cancelState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIButton) {
        product = product ?? Product(context: context)
        var errorMessage: String = ""
        
        if let name = tfName.text, name.count > 0 {
            product.name = name
        }
        else {
            errorMessage += "Nome do Produto é obrigatório \n"
        }
        
        if let value = tfPrice.text, let dValue = Double(value), dValue >= 0 {
            product.price = dValue
        }
        else {
            errorMessage += "Preço é valor numérico obrigatório \n"
        }
        
        product.usedCreaditCard = spCreditCard.isOn
        if currentState != nil {
            product.state = currentState
        }
        else {
            errorMessage += "Estado é obrigatório \n"
        }
            
        if smallImage != nil {
            product.picture = smallImage
        }
        else {
            errorMessage += "A imagem do produto é obrigatória"
        }
        
        if errorMessage.count > 1 {
            let alert = UIAlertController(title: "Atenção", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            context.undo()
            return
        }
        
        do {
            try context.save()
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }

    func setNewImage(sourceType: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = sourceType
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.setNewImage(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.setNewImage(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
//        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
//            self.setNewImage(sourceType: .savedPhotosAlbum)
//        }
//        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension RegisterProductViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView.reloadComponent(0)
    }
}

extension RegisterProductViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let path = IndexPath(row: row, section: 0)
        let state:State = fetchedResultController.object(at: path)
        if let name = state.name {
            return name
        }
        return ""
    }
}

extension RegisterProductViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            return count
        } else {
            return 0
        }
    }
}

extension RegisterProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?){
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivImage.image = smallImage
        
        dismiss(animated: true, completion: nil)
    }
}



