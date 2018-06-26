//
//  ImageGalleryListTableViewController.swift
//  ImageGallery
//
//  Created by Sajad on 6/26/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit

class ImageGalleryListTableViewController: UITableViewController {

    var imageGalleries = [ImageGallery]()
    var deletedGallaries = [ImageGallery]()
    
    var sectionCount: Int {
        return deletedGallaries.count > 0 ? 2 : 1
    }
    
    var sectionTitles: [String] {
        return ["Galleries",
                "Recently Deleted"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        let name = "Untitled".madeUnique(withRespectTo: imageGalleries.map { return $0.name })
        imageGalleries += [ImageGallery(with: name, items: [])]
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? imageGalleries.count : deletedGallaries.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    private func galleryFor(indexPath: IndexPath) -> ImageGallery? {
        switch indexPath.section {
        case 0:
            return imageGalleries[indexPath.row]
        case 1:
            return deletedGallaries[indexPath.row]
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Gallery Name Cell", for: indexPath) as! ImageGalleryListTableViewCell

        if let gallery = galleryFor(indexPath: indexPath) {
            cell.nameTextField.text = gallery.name
            cell.delegate = self
        }
    
        return cell
    }
    
    private func deleteGalleryAt(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let gallery = imageGalleries.remove(at: indexPath.row)
            deletedGallaries.append(gallery)
            
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .fade)
                if tableView.numberOfSections == 1 {
                    tableView.insertSections(IndexSet(integer: 1), with: .fade)
                }
                tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1), section: 1)], with: .fade)
            })
        case 1:
            deletedGallaries.remove(at: indexPath.row)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .fade)
                if deletedGallaries.count == 0 {
                    tableView.deleteSections(IndexSet(integer: 1), with: .fade)
                }
            })
            
            
        default:
            break
        }
        
    }
    
    private func restoreGallery(fromIndexPath indexPath: IndexPath) {
        let gallery = deletedGallaries.remove(at: indexPath.row)
        imageGalleries.append(gallery)
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .fade)
            if deletedGallaries.count == 0 {
                tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            }
            tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
        })
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            return UISwipeActionsConfiguration(actions:
                [UIContextualAction(style: .normal,
                                    title: "Restore",
                                    handler: { (action, sourceView, completionHanlder) in
                                        self.restoreGallery(fromIndexPath: indexPath)
                                        completionHanlder(true)
                                    }
                                    )
                ]
            )
        } else {
            return nil
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGalleryAt(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showImageGallery", sender: indexPath)
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageGallery",
            let indexPath = sender as? IndexPath,
            indexPath.section == 0,
            let destination = segue.destination.contents as? ImageGalleryViewController {
            destination.imageGallery = self.imageGalleries[indexPath.row]
        }
    }
    

}

extension ImageGalleryListTableViewController: ImageGalleryListTableViewCellDelegate {
    func imageGallerListCell(_ cell: ImageGalleryListTableViewCell, didChangeNameTo name: String) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let gallery = indexPath.section == 0 ? imageGalleries[indexPath.row] : deletedGallaries[indexPath.row]
            gallery.name = name
        }
    }
}
