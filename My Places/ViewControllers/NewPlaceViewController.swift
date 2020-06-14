//
//  NewPlaceViewController.swift
//  My Places
//
//  Created by kris on 20/05/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var saveAction: UIBarButtonItem!
    @IBOutlet weak var ratingControl: ReitingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        saveAction.isEnabled = false
        placeName.addTarget(self, action: #selector(changePlaceName), for: .editingChanged)
        setupEditScrean()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
             
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else {return}
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
        mapVC.place.name = placeName.text!
        mapVC.place.location = placeLocation.text
        mapVC.place.type = placeType.text
        mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
   
    func savePlace() {
        
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
    
         let newPlace = Place(name: placeName.text!,
                              location: placeLocation.text,
                              type: placeType.text,
                              imageData: imageData,
                              rating: Double(ratingControl!.rating)
        )
    
    if currentPlace != nil {
        try! realm.write {
            currentPlace?.imageData = newPlace.imageData
            currentPlace?.name = newPlace.name
            currentPlace?.location = newPlace.location
            currentPlace?.type = newPlace.type
            currentPlace?.rating = newPlace.rating
        }
    } else {
        StorageManager.saveObjekt(place: newPlace)
      }
}
    
    
    private func setupEditScrean() {
        
        if currentPlace != nil {
            
            setupNavigationBar()
            
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar() {
        
       if let topItem = navigationController?.navigationBar.topItem {
        topItem.backBarButtonItem = .init(title: "", style: .plain, target: nil, action: nil)
       }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveAction.isEnabled = true
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
     
// MARK: Text field Deligate
// скрываем клавиатуру по нажатию на Done
extension NewPlaceViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
        @objc private func changePlaceName() {
        
            if placeName.text?.isEmpty == false {
                saveAction.isEnabled = true
            } else {
                saveAction.isEnabled = false
            }
        }
}
    
// MARK: Work with Image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(address: String?) {
        placeLocation.text = address
    }
}
