//
//  UIViewController+CoreData.swift
//  ComprasUSA
//
//  Created by Luiz Aquino on 07/10/17.
//  Copyright © 2017 Luiz Aquino. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
