//
//  PeriodicTableCollectionViewController.swift
//  AC3.2-PeriodicTable
//
//  Created by Tom Seymour on 12/21/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ElementCell"

class PeriodicTableCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var fetchedResultsController: NSFetchedResultsController<Element>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib(nibName:"ElementCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        getData()
        initializeFetchedResultsController()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("No sections in fetchedResultsController")
            return 0
        }
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let sections = fetchedResultsController.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        let sectionInfo = sections[section]
        return 7//sectionInfo.numberOfObjects
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections")
        }
        let numberOfThingsInSection = sections[indexPath.section].numberOfObjects
        let offset = 7 - numberOfThingsInSection
        
        if indexPath.row < offset {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
        } else {
            let offsettedIndexPath: IndexPath = [indexPath.section, indexPath.row - offset]
            let element = fetchedResultsController.object(at: offsettedIndexPath)
            return getElementCell(indexPath: indexPath, collectionView: collectionView, element: element)
        }
        
    }
    
    func getElementCell(indexPath: IndexPath, collectionView: UICollectionView, element: Element) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ElementCollectionViewCell

        cell.elementView.symbolLabel.text = element.symbol
        cell.elementView.numberLabel.text = String(element.number)
        
        switch element.number {
        case 1, 6, 7, 8, 15, 16, 34:
            cell.elementView.backgroundView.backgroundColor = .cyan //teal
        case 2, 10, 18, 36, 54, 86:
            cell.elementView.backgroundView.backgroundColor = .brown
        case 3, 11, 19, 37, 55, 87:
            cell.elementView.backgroundView.backgroundColor = .blue
        case 5, 12, 20, 38, 56, 88:
            cell.elementView.backgroundView.backgroundColor = .purple
        case 21...30, 39...48, 72...80, 104...112:
            cell.elementView.backgroundView.backgroundColor = .red
        case 5, 14, 32, 33, 51, 52, 84:
            cell.elementView.backgroundView.backgroundColor = .yellow
        case 9, 17, 35, 53, 85:
            cell.elementView.backgroundView.backgroundColor = .green
        case 13, 31, 49, 50, 81...83:
            cell.elementView.backgroundView.backgroundColor = .orange
        case 113...118:
            cell.elementView.backgroundView.backgroundColor = .lightGray
        case 57:
            cell.elementView.backgroundView.backgroundColor = .magenta
        case 89:
            cell.elementView.backgroundView.backgroundColor = .darkGray
        default:
            break
        }
        return cell
    }
    
    func getData() {
        APIRequestManager.manager.getData(endPoint: "https://api.fieldbook.com/v1/5859ad86d53164030048bae2/elements")  { (data: Data?) in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options:[]) {
                    if let arrayOfElements = jsonData as? [[String:Any]] {
                        
                        let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.privateContext
                        
                        moc.performAndWait {
                            for elDict in arrayOfElements {
                                let element = NSEntityDescription.insertNewObject(forEntityName: "Element", into: moc) as! Element
                                element.populate(from: elDict)
                            }
                            do {
                                try moc.save()
                                
                                moc.parent?.performAndWait {
                                    do {
                                        try moc.parent?.save()
                                    }
                                    catch {
                                        fatalError("Failure to save context: \(error)")
                                    }
                                }
                            }
                            catch {
                                fatalError("Failure to save context: \(error)")
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func initializeFetchedResultsController() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        
        let request = NSFetchRequest<Element>(entityName: "Element")
        let predicate = NSPredicate(format: "group < %@", "19")
        request.predicate = predicate
        
        let numberSort = NSSortDescriptor(key: "number", ascending: true)
        let groupSort = NSSortDescriptor(key: "group", ascending: true)
        request.sortDescriptors = [groupSort, numberSort]
        
        do {
            let els = try moc.fetch(request)
            for el in els {
                print("\(el.group) \(el.number) \(el.symbol)")
            }
        }
        catch {
            print("error fetching")
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "group", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }


    
    // MARK: UICollectionViewDelegate
   
    private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        
//        return CGSize(width: widthPerItem, height: widthPerItem * 1.7)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
