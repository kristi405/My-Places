//
//  MainViewController.swift
//  My Places
//
//  Created by kris on 14/05/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit
import RealmSwift


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredPlaces: Results<Place>!
    private var places: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltred: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sortingButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search place"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltred {
            return filtredPlaces.count
        }
            return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltred ? filtredPlaces[indexPath.row] : places[indexPath.row]

        cell.NameLabel?.text = place.name
        cell.LocationLabel.text = place.location
        cell.TypeLabel.text = place.type
        cell.ImageOfPlaces.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating

        // изменяем размер картинки
        let itemSize = CGSize(width: cell.frame.size.height, height: cell.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
        let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell.ImageOfPlaces.image?.draw(in: imageRect)
        cell.ImageOfPlaces.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
                
        return cell
    }    
   
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltred ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_segue: UIStoryboardSegue){
        
        guard let newPlaceVC = _segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func selectedSorting(_ sender: UISegmentedControl) {
       sorting()
    }
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            sortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
    
        tableView.reloadData()
     }
}

     // MARK: Extension of searching and filtring

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        filtredContent(searchText: searchController.searchBar.text!)
    }
    
    private func filtredContent(searchText: String) {
        
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
