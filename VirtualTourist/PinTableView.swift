//
//  PinTableView.swift
//  VirtualTourist
//
//  Created by CarlJohan on 10/05/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import CoreData

class PinViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?{
        didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as MapPin
        // predicate = si
        // du fortæller predicate hvad du vil have, lidt som en si
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath)
        
        // Set up the cell
        guard let pin = self.fetchedResultsController?.object(at: indexPath) as? Pin else {
            print("Attempt to configure cell without a managed object")
            return cell
        }
    
        cell.textLabel?.text = "\(pin.latitude) | \(pin.longitude)"
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        guard let fc = fetchedResultsController else {
            print("No sections in fetchedResultsController")
            return 0
        }
        return fc.sections![section].numberOfObjects
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*guard let pin = self.fetchedResultsController?.object(at: indexPath) as? Pin else {
            print("Attempt to configure cell without a managed object")
            return
        }*/
        
        performSegue(withIdentifier: "displayNoteSegue", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "displayNoteSegue" {
            
            if let photoTableVC = segue.destination as? PhotosViewController {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]

                
                let indexPath = tableView.indexPathForSelectedRow!
                let pin = fetchedResultsController?.object(at: indexPath) as? Pin
                
                //let pred = NSPredicate(format: "Pin = %@", argumentArray: [pin!])
                
                //fetchRequest.predicate = pred
                
                // Create FetchedResultsController
                //let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                //photoTableVC.fetchedResultsController = frc
                
                photoTableVC.pin = pin
                
            }
        }
    }
    
}
