 //
//  CategoryViewController.swift
//  ToDo
//
//  Created by Владимир Коваленко on 09.07.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
 
class CategoryViewController: SwipeTableViewController  {
    
     var categories = [Categories]()
    
     let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
          guard let navBar = navigationController?.navigationBar else {fatalError("nav controller doesn't exist ")}
        navBar.barTintColor = UIColor(hexString: "CCAFAF")
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { ( action) in
            //what will happen after click addItem
            let newCategory = Categories(context: self.context )
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
           let category = categories[indexPath.row]
           cell.textLabel?.text = category.name
        guard let categoryColor = UIColor(hexString: category.colour ?? "CCAFAF") else {
            fatalError()
        }
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        cell.backgroundColor = categoryColor
        
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
         // MARK: -  Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        
        let category = self.categories[indexPath.row]
        self.context.delete(category)
        self.categories.remove(at: indexPath.row)
        }
    }


  
 
