//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Vladimir Kravets on 21.10.2022.
//

import UIKit
import Cosmos


class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    
    //var newPlace = Place()
    
    var imageIsChanged = false
    var currentRating = 0.0
    
    
    @IBOutlet weak var placeName: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeLocation: UITextField!
    
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: -read data from bace
        //        DispatchQueue.main.async {
        //            self.newPlace.savePlaces()
        //        }
        
        //MARK: -chamged empty rows to UIView
        //tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1) )
        self.tableView.separatorStyle = .none
        //tableView.tableFooterView = UIView(frame: .zero)
        
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        
        setupEditScreen()
        //cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    //MARK: -Table View delegate (image add)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    
    //MARK: -prepaer for sender (Navigation)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else {return}
        
        mapVC.incomeSegueIdentifier = identifier
        
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
        
        //    if segue.identifier != "showPlace" { return }
        //    let mapVC = segue.destination as! MapViewController
        //       mapVC.place = currentPlace
        
    }
    
    
    //MARK: - func that edit chabges in existing row or creat a new one
    func savePlace() {
        
        //        let newPlace = Place()
        
        let image = imageIsChanged ? placeImage.image : UIImage(named: "imagePlaceholder")
        
        //        if imageIsChanged {
        //            image = placeImage.image
        //        } else {
        //            image = UIImage(named: "imagePlaceholder")
        //        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: currentRating)
        if currentPlace != nil {
            try! realm.write{
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        
        
        //    MARK: -init inside func use let newPlace = Place()
        //        newPlace.name = placeName.text!
        //        newPlace.location = placeLocation.text
        //        newPlace.type = placeType.text
        //        newPlace.imageData = imageData
        
        //        newPlace = Place(name: placeName.text ?? "" , location: placeLocation.text, type: placeType.text, image: image, restaurantImage: nil)
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
        }
        
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: -Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    //MARK: -hide keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        
        
    }
}

//MARK: - work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
            
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFit
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
    
    
}
