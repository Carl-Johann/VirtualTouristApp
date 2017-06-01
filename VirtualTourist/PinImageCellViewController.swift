//
//  PinImageView.swift
//  VirtualTourist
//
//  Created by CarlJohan on 26/04/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var MapPinView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var deleteSelectedButton: UIButton!
    
    
    // MARK: - Class Variables and Constants
    var collectionViewPin: Pin?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var numberOfCellsInCollectionView: Int?
    
    lazy var fetchedResultsController = { () -> NSFetchedResultsController<Photo> in
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    // MARK: - View override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [collectionViewPin!])
        fetchedResultsController.fetchRequest.predicate = predicate
        
        //
        do { try fetchedResultsController.performFetch()
        } catch { print("ERROR: \(error)") }
        
        
        setupMapAnnotation()
        setupCollectionView()
    }
    
    
    
    // MARK: - IBActions
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        guard let pin = collectionViewPin else { print("collectionViewPin = nil");return }
        
        pin.removeFromPhotos(pin.photos!)
        self.saveInContext()
        
        DispatchQueue.main.async {
            self.photosCollectionView.reloadData()
        }
        
        print()
        
        DispatchQueue.main.async {
            FlickrClient.sharedInstance.getImagesForPin(self.collectionViewPin!.latitude, self.collectionViewPin!.longitude) { (downloadedPhotos, succes) in
                if succes == false { print("An error occured trying to fetch images from Flickr"); return }
                
                self.numberOfCellsInCollectionView = downloadedPhotos.count
                // If the photos were succesfully downloaded, we remove all photos from the pin.
                
                
                for photo in downloadedPhotos {
                    let newPhoto = Photo(context: self.appDelegate.stack.context)
                    
                    guard let photoURL = photo["url_s"] as? String else { print("ERROR: PinImageCellViewController. Couldn't find 'url_s' in 'photos'")
                        self.newCollectionButton.isEnabled = true; return }
                    
                    newPhoto.imageURL = photoURL
                    newPhoto.pin = pin
                    pin.addToPhotos(newPhoto)
                    
                    
                }
                self.saveInContext()
                DispatchQueue.main.async {
                    self.photosCollectionView.reloadData()
                }
                
                for photo in pin.photos! {
                    self.imageFromURL(photo as! Photo)
                }
                
            }
        }
    }
    
    
    
    @IBAction func deleteSelectedItemsButton(_ sender: Any) {
        let itemIndexPaths = photosCollectionView.indexPathsForSelectedItems!
        var selectedManagedObjectsFromObjectID = [NSManagedObject]()
        
        
        for indexPath in itemIndexPaths {
            let cell = photosCollectionView.cellForItem(at: indexPath) as! PhotoCell
            guard let photoFromCell = cell.associatedPhoto else { print("cell.associatedPhoto was not succesfully unwrapped"); return }
            
            let object = appDelegate.stack.context.object(with: photoFromCell.objectID)
            selectedManagedObjectsFromObjectID.append(object)
            
        }
        let managedObjectsToDeleteAsNSSet = NSSet(array: selectedManagedObjectsFromObjectID )
        
        
        
        self.photosCollectionView.performBatchUpdates({
            
            self.photosCollectionView.deleteItems(at: itemIndexPaths)
            self.collectionViewPin?.removeFromPhotos(managedObjectsToDeleteAsNSSet)
            
        }) { (true) in
            self.saveChangesAndSetButtons()
        }
        
    }
    
    
    
    
    
    
    // MARK: - Convenience Methods
    
    //
    func saveInContext() {
        do { try self.appDelegate.stack.saveContext()
        } catch { print("An error occured trying to save core data") }
    }
    
    
    func saveChangesAndSetButtons() {
        saveInContext()
        DispatchQueue.main.async {
            
            self.deleteSelectedButton.isHidden = true
            self.newCollectionButton.isHidden = false
            
            self.photosCollectionView.reloadData()
        }
    }
    
    
    //
    func setupMapAnnotation() {
        
        let annotation = MKPointAnnotation()
        let coordinateFromPin = CLLocationCoordinate2D(latitude: collectionViewPin!.latitude, longitude: collectionViewPin!.longitude)
        
        annotation.coordinate = coordinateFromPin
        self.MapPinView.addAnnotation(annotation)
    }
    

    
    //
    func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let mapCoordinate = CLLocationCoordinate2D(latitude: collectionViewPin!.latitude, longitude: collectionViewPin!.longitude)
        
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        photosCollectionView.contentInset = UIEdgeInsets(top: 2, left: 3, bottom: 0, right: 3)
        
        
        let coordinateSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let mkCoordination: MKCoordinateRegion = MKCoordinateRegion(center: mapCoordinate, span: coordinateSpan)
        MapPinView.setRegion(mkCoordination, animated: true)
        
        photosCollectionView.allowsMultipleSelection = true
        
        photosCollectionView.collectionViewLayout = layout
        photosCollectionView.reloadData()
    }
    
    
    
    //
    func imageFromURL( _ photo: Photo) {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let url = URL(string: photo.imageURL!)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            photo.image =  UIImagePNGRepresentation(imageFromURL!) as NSData?
        
            self.saveInContext()
        }
    }
    
    
    
    
    
    
    // MARK: - Core Data Delegate Methods
    
    //
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            print("deleted an object")
        case .insert:
            print("inserted an object")
        case .move:
            print("moved an object")
        case .update:
            print("updated an object")
            
            if let index = indexPath, let cell = photosCollectionView.cellForItem(at: index) as? PhotoCell {
                configureCell(index, cell)
            }
            
        }
    }
    
    
    
    
    
    // MARK: - CollectionView Methods
    
    func configureCell(_ index: IndexPath, _ cell: PhotoCell) {
        let photo = fetchedResultsController.object(at: index)

        let imageFromNSData = UIImage(data: photo.image! as Data)

        cell.cellImage.image = imageFromNSData
        cell.cellLoadingIndicator.stopAnimating()
        cell.cellImage.isHidden = false
    }
    
    
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinPhotoCell", for: indexPath) as! PhotoCell
        
        cell.backgroundColor = UIColor.lightGray
        cell.cellLoadingIndicator.startAnimating()
        cell.cellImage.isHidden = true
        
        guard let unwrappedPin = collectionViewPin else { print("pin = nil"); return cell }
        guard let photos = unwrappedPin.photos else { print("'photosFromPin = nil'"); return cell }
        let photosAsAnArray = Array(photos)
        
        
        let photoAtIndexPath = photosAsAnArray[indexPath[1]] as! Photo
        cell.associatedPhoto = photoAtIndexPath
        
        
        
        guard photoAtIndexPath.imageURL != nil else { print("No imageURL was found"); return cell }
        guard photoAtIndexPath.image != nil else { print("No image, but there was a URL.")
            return cell
        }
        
        
        
        let imageFromNSData = UIImage(data: photoAtIndexPath.image! as Data)
        
        
        
        cell.cellImage.image = imageFromNSData
        cell.cellImage.isHidden = false
        cell.cellLoadingIndicator.stopAnimating()
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let unwrappedPin = collectionViewPin else { print("pin = nil"); return 0 }
        guard let photos = unwrappedPin.photos else { print("'photosFromPin = nil'"); return 0 }
        //guard let numberOfCellsInCV = numberOfCellsInCollectionView else { print("'numberOfCellsInCollectionView'"); return 0}
        
        return photos.count
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let CVWidth = collectionView.frame.width
        let numberOfItemsPerRow: CGFloat = 3.0
        
        let itemSize = (CVWidth/numberOfItemsPerRow) - 4
        
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedCell.alpha = 0.5
        self.checkAndUpdateView(selectedCell)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        selectedCell.alpha = 1
        self.checkAndUpdateView(selectedCell)
        
    }
    
    // MARK: - CollectionView Convenience Methods
    
    func checkAndUpdateView(_ selectedCell: PhotoCell) {
        
        if photosCollectionView.indexPathsForSelectedItems?.count != 0 {
            
            newCollectionButton.isHidden = true
            deleteSelectedButton.isHidden = false
            
        } else {
            if photosCollectionView.indexPathsForSelectedItems?.count == 0 {
                
                newCollectionButton.isHidden = false
                deleteSelectedButton.isHidden = true
                
            }
        }
    }
    
    
}


// MARK: - PhotoCell Class
class PhotoCell: UICollectionViewCell{
    
    var associatedPhoto: Photo?
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    
}
