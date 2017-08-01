//
//  FetchedResultsTableViewController.swift
//  SmashtagA5
//
//  Created by Paul Hegarty on 2/3/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    lazy var allCellsWereVisible: Bool = {
        [unowned self] in
        return self.areAllCellsVisible()
    }()
    
    private func areAllCellsVisible() -> Bool {
        return tableView.numCells == tableView.visibleCells.count
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        // Fixes bug where footer gets stuck to bottom of table view when cells are deleted such that all the cells become visible on screen.
//        let cellsAreVisible = areAllCellsVisible()
//        if (allCellsWereVisible != cellsAreVisible) {
//            allCellsWereVisible = cellsAreVisible
//            tableView.reloadData()
//        }
    }
}


extension UITableView {
    var numCells: Int {
        var count = 0
        let numSections = self.numberOfSections
        for i in 0..<numSections {
            count += self.numberOfRows(inSection: i)
        }
        
        return count
    }
}
