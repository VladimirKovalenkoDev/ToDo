 //
//  CategoryViewController.swift
//  ToDo
//
//  Created by Владимир Коваленко on 09.07.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import CoreData
 
class CategoryViewController: UITableViewController {
    
     var categories = [Categories]()
    
     let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { ( action) in
            //what will happen after click addItem
            let newCategory = Categories(context: self.context )
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            self.saveData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Crete new item"
            
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
           let category = categories[indexPath.row]
           cell.textLabel?.text = category.name
           return cell
    }
  // MARK: - Table View Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
   
  
  
    // MARK: - Data Source Manipulations
    func saveData () {
             do {
                try  context.save()
             } catch {
             print("error saving context: \(error)")
             }
            
             self.tableView.reloadData()
        }
        
        func loadData(with request:NSFetchRequest<Categories> = Categories.fetchRequest()) {
            do {
               categories =  try context.fetch(request)
            } catch  {
                print("error fetching data from context:\(error)")
            }
            tableView.reloadData()
        }
        
    }
 
