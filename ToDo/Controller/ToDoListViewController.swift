//
//  ViewController.swift
//  ToDo
//
//  Created by Владимир Коваленко on 24.06.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    
    @IBOutlet weak var toDoListSearchbar: UISearchBar!
    var itemArray = [Item]()
    let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Categories? {
        didSet{
            loadData()
           
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        if let colourHex = selectedCategory?.colour {
             title = selectedCategory!.name
          //tableView.backgroundColor = UIColor(hexString: colourHex)
             guard let navBar = navigationController?.navigationBar else {fatalError("nav controller doesn't exist ")}
            
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
               toDoListSearchbar.barTintColor = navBarColour
            }
        }
    }

 // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        //Ternary operator ==>
        // value = condition ? valueIfTrue : ValueIfFalse
        
        if let colour = UIColor(hexString: selectedCategory!.colour ?? "CCAFAF")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray.count)) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
   
// MARK: - Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { ( action) in
            //what will happen after click addItem
            let newItem = Item(context: self.context )
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
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
    
    // MARK: - Work with data
    func saveData () { 
         do {
            try  context.save()
         } catch {
         print("error saving context: \(error)")
         }
        
         self.tableView.reloadData()
    }
    
    func loadData(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
       
        do {
           itemArray =  try context.fetch(request)
        } catch  {
            print("error fetching data from context:\(error)")
        }
        tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
        
        let item = self.itemArray[indexPath.row]
               self.context.delete(item)
               self.itemArray.remove(at: indexPath.row)
    }
    
}
// MARK: - SearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
       loadData(with: request, predicate: predicate )
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder() 
            }
        }
    }
}
