//
//  ViewController.swift
//  ToDo
//
//  Created by Владимир Коваленко on 24.06.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var itemArray = [Item]()
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
      loadData()
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        //Ternary operator ==>
        // value = condition ? valueIfTrue : ValueIfFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
      //  itemArray.remove(at: indexPath.row)
       // context.delete(itemArray[indexPath.row])
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { ( action) in
            //what will happen after click addItem
            let newItem = Item(context: self.context )
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            self.saveData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Crete new item"
            
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    
    
    func saveData () {
        
         do {
            try  context.save()
         } catch {
         print("error saving context: \(error)")
         }
        
         self.tableView.reloadData()
    }
    
    func loadData() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        do {
           itemArray =  try context.fetch(request)
        } catch  {
            print("error fetching data from context:\(error)")
        }
    }
    
}

