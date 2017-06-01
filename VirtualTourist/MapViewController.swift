//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var pinGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    @IBOutlet weak var tapToDeleteLabel: UILabel!
    
    // Class Variables and Constants
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var annotations: [MKAnnotation] = [MKAnnotation]()
    var selectedAnnotation: MKAnnotation?
    var editStatus: Bool?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            // Fetch all pins from core data
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
            
            let context = self.appDelegate.stack.context
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Failed to initialize FetchedResultsController: \(error)")
            }
            
            // Makes an annotation from all fetched objects
            for pin in fetchedResultsController.fetchedObjects! as! [Pin] { self.makeAnnotationFromCoreData(pin) }
            
            // Adds them to the mapView
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editStatus = false
        
    }
    
    // MARK: - @IBAction's
    @IBAction func editDoneButton(_ sender: Any) {
        if editStatus == false {
            editStatus = true
            tapToDeleteLabel.alpha = 1
            
        } else {
            editStatus = false
            tapToDeleteLabel.alpha = 0
            
            do { try self.appDelegate.stack.saveContext()
            } catch { print("An error occured trying to save core data") }
        }
        
        self.setEditing(!self.isEditing, animated: true)
        let newButton = UIBarButtonItem(barButtonSystemItem: (self.isEditing) ? .done : .edit, target: self, action: #selector(editDoneButton(_:)))
        self.navigationItem.setRightBarButton(newButton, animated: false)
        
    }
    
    
    @IBAction func pinGesureRecognizer(_ sender: Any) {
        if self.pinGestureRecognizer.state == .ended {
            
            // Creates an annotatin and adds it to the mapView
            let annotation = makeAnAnnotation()
            self.mapView.addAnnotation(annotation)
            
            // Retrieves and sets the latitude and longitude from the newly created annotation
            let latitude = annotation.coordinate.latitude as Double
            let longitude = annotation.coordinate.longitude as Double
            
            //
            DispatchQueue.main.async {
                //
                FlickrClient.sharedInstance.getImagesForPin(latitude, longitude) { (photos, success) in
                    if success != true { print("An error occured trying to download images for the created pin"); return }
                    
                    // Creating and setting up a new pin
                    let newPin = Pin(context: self.appDelegate.stack.context)
                    
                    newPin.latitude = latitude
                    newPin.longitude = longitude
                    
                    // Adding photos to the newly created pin 'newPin', and assigning the photos pin to 'newPin'
                    for photo in photos {
                        let pinPhoto = Photo(context: self.appDelegate.stack.context)//self.setupPinPhoto(photo)
                        
                        guard let photoURL = photo["url_s"] as? String else { print("ERROR: MapViewController. Couldn't find 'url_s' in 'photo'"); return }
                        
                        pinPhoto.imageURL = photoURL
                        pinPhoto.pin = newPin
                        newPin.addToPhotos(pinPhoto)
                    }
                    
                    // Saving changes in context
                    do { try self.appDelegate.stack.saveContext()
                    } catch { print("An error occured trying to save core data, after adding a pin ") }
                
                    for photo in newPin.photos! {
                        self.imageFromURL(photo as! Photo)
                    }
                
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ClickedPinSegueToCell" {
            let pinCellVC = segue.destination as! PhotoAlbumViewController
            
            //
            let pinFromAnnotation = self.pinFromSelectedAnnotation()
            pinCellVC.collectionViewPin = pinFromAnnotation
            
            //do { try pinCellVC.fetchedResultsController.performFetch()
            //} catch { print("ERROR \(error)")}
            pinCellVC.numberOfCellsInCollectionView = pinFromAnnotation.photos?.count
            
        }
    }
    
    
    
    // MARK: - Methods/Functions
    
    
    //
    func pinFromSelectedAnnotation() -> Pin {
        
        // Creates a fetchrequest to fetch the pin from the selected annotation
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "latitude", ascending: true) ]
        
        let context = appDelegate.stack.context
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        // The annotation selected from the mapView
        guard let annotation = selectedAnnotation else { print("'selectedAnnotation = nil'"); return Pin(context: context) }
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        // Creates a prediacte to fetch the pin from the selected annotations latitude and longitude
        let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitude, longitude])
        fetchRequest.predicate = pred
        // Sets the fetchlimit to 1, incase two pins, for some reason, should share the same latitude and longitude
        fetchRequest.fetchLimit = 1
        
        //
        do { try fetchedResultsController.performFetch()
        } catch { print("Failed to initialize FetchedResultsController: \(error)") }
        
        
        // 
        // I use '.first' because i have set the fetchrequest limit to '1'
        guard let pinFromAnnotation = fetchedResultsController.fetchedObjects?.first as? Pin else {
            print("no pin found from latitude and/or longitude from clicked annotation")
            return Pin(context: context)
        }
        
        return pinFromAnnotation
    }
    
    
    //
    func makeAnnotationFromCoreData(_ pin: Pin) {
        
        let annotationFromCoreData = MKPointAnnotation()
        let annotationCoordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotationFromCoreData.coordinate = annotationCoordinate
        self.annotations.append(annotationFromCoreData)
    }
    
    
    //
    func makeAnAnnotation() -> MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        
        let xValue = pinGestureRecognizer.location(in: self.mapView).x
        let yValue = pinGestureRecognizer.location(in: self.mapView).y
        
        let mapPoint = CGPoint(x: xValue,y:  yValue)
        let coordinateFromTouch = self.mapView.convert(mapPoint, toCoordinateFrom: self.mapView)
        
        annotation.coordinate = coordinateFromTouch
        self.annotations.append(annotation)
        
        return annotation
    }
    
    
    //
    
    
    
    //
    func imageFromURL( _ photo: Photo) {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            let url = URL(string: photo.imageURL!)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            photo.image =  UIImagePNGRepresentation(imageFromURL!) as NSData?
            
            do { try self.appDelegate.stack.context.save()
            } catch { print("ERROR: \(error)") }
        }
    }
    
    
    
    // MARK: - mapView Methods
    
    //
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation
        
        switch editStatus! {
        case false:
            performSegue(withIdentifier: "ClickedPinSegueToCell", sender: self)
            
        case true:
            deletePin()
        }
    }
    
    
    //
    func deletePin() {
        
        let selectedPin = pinFromSelectedAnnotation()
        let context = appDelegate.stack.context
        
        context.delete(selectedPin)
        mapView.removeAnnotation(self.selectedAnnotation!)
        
        
    }
    
}
