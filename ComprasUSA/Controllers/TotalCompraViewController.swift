//
//  TotalCompraViewController.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 16/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import UIKit
import CoreData

class TotalCompraViewController: UIViewController {
 
    @IBOutlet weak var lbTotalDollar: UILabel!
    @IBOutlet weak var lbTotalReais: UILabel!
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didLoad")
        loadProducts()
    }

    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
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
    
    func calculateTotal() {
        print("calculateTotal")
        if let objects = fetchedResultController.fetchedObjects {
            print("objects")
            var dollarResult = 0.0;
            let dollarPrice = UserDefaults.standard.double(forKey: "dollar")
            let iof = UserDefaults.standard.double(forKey: "iof")
            for product in objects {
                var productTotal = product.price
                if let state = product.state {
                    productTotal *= state.tax
                }
                if product.usedCreaditCard {
                    productTotal *= iof
                }
                dollarResult += productTotal
            }
            let brlResult = dollarResult * dollarPrice
            lbTotalReais.text = String(format: "%.2f", brlResult)
            lbTotalDollar.text = String(format: "%.2f", dollarResult)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TotalCompraViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("didChangeContent")
        calculateTotal()
    }
}

