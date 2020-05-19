//
//  MainViewController.swift
//  My Places
//
//  Created by kris on 14/05/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    let cafeName = ["Ташкент", "Цельсий", "Планета", "Венеция", "Амстердам", "Авеню", "Параграф", "Жемчуг", "Лофт", "Корова", "Кайот", "Бригантина", "Проспект", "Клюква", "Марио"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafeName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.NameLabel?.text = cafeName[indexPath.row]
        cell.ImageOfPlaces.image = UIImage(named: cafeName[indexPath.row])
      
        // изменяем размер картинки
        let itemSize = CGSize(width: cell.frame.size.height, height: cell.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
        let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell.ImageOfPlaces.image?.draw(in: imageRect)
        cell.ImageOfPlaces.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.ImageOfPlaces.layer.cornerRadius = cell.ImageOfPlaces.frame.size.height / 2
        cell.ImageOfPlaces.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
