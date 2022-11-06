//
//  MYTableViewController.swift
//  MyPlaces
//
//  Created by Vladimir Kravets on 20.10.2022.
//

import UIKit
import RealmSwift

class MYTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places : Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var revesredSortingButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - show model Place.self
        places = realm.objects(Place.self)
        // MARK: -setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Serch"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        //        var place = Place()
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        //        if isFiltering {
        //            place = filteredPlaces[indexPath.row]
        //        } else {
        //            place = places[indexPath.row]
        //        }
        
        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        //        if place.image == nil {
        //        cell.imageOfPlace?.image = UIImage(named: place.restaurantImage ?? "imagePlaceholder")
        //        } else {
        //            cell.imageOfPlace.image = place.image
        //        }
        
        cell.cosmosView.rating = place.rating
        
        
        
        return cell
    }
    
    //MARK: - Table View Delegate delte rows in Cell
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    
    // MARK: - Navigation go to NewPlaceVC to editing exist info
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            //MARK: -creat экземпляр модели
            //let place : Place
            //var place = Place()
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places [indexPath.row]
            //            if isFiltering {
            //                place = filteredPlaces[indexPath.row]
            //            } else {
            //                place = places [indexPath.row]
            //            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
        
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        
        newPlaceVC.savePlace()
        //        places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }
    //MARK: -sort by date and name
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        if ascendingSorting {
            revesredSortingButton.image = UIImage(named: "AZ")
        } else {
            revesredSortingButton.image = UIImage(named: "ZA")
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

extension MYTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
