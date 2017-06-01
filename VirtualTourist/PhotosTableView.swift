//
//  PhotosTableView.swift
//  VirtualTourist
//
//  Created by CarlJohan on 10/05/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import CoreData

class PhotosViewController: UITableViewController {

    var pin: Pin?
    
    /*var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet { fetchedResultsController?.delegate = self as? NSFetchedResultsControllerDelegate }
    }*/
    

    override func viewDidLoad() {
        super.viewDidLoad()

        /*do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }*/

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as MapPin
        // predicate = si
        // du fortæller predicate hvad du vil have, lidt som en si
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        
        guard let selectedPin = pin else { print("Pin = nil"); return cell }
        guard let pinPhots = selectedPin.photos?.allObjects else { print("'SelectedPin' doens't have any photos"); return cell }
        guard let photo = pinPhots[indexPath[1]] as? Photos else { print("Couldn't find photo at indexPath[1]"); return cell }
        //cell.imageView?.image = UIImage() //photo.photoURL
      
        let url = URL(string: photo.photoURL!)
        let data = try? Data(contentsOf: url!)
        cell.imageView?.image = UIImage(data: data!)
                
        return cell
        
        //cell.textLabel?.text = "\(selectedPin.latitude) | \(selectedPin.longitude)"
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*guard let fc = fetchedResultsController else {
            print("No sections in fetchedResultsController")
            return 0
        }
        
        
        return fc.sections![section].numberOfObjects*/
        guard let selectedPin = pin else { print("Pin = nil"); return 0 }
        
        return selectedPin.photos!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}

