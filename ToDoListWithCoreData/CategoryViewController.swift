//
//  CategoryVC.swift
//  ToDoListWithCoreData
//
//  Created by Alibek Kozhambekov on 10.01.2023.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let cellIdentifier = "categoryIdentifier"
    let nsContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        loadCategories()
    }
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    @IBAction func addActionPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category to your list", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            
            let newCategory = Category(context: self.nsContext)
            newCategory.name = textField.text
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manupilation
    
    fileprivate func saveCategories() {
        do {
            try nsContext.save()
        } catch {
            print("Error in saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    fileprivate func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try nsContext.fetch(request)
        } catch {
            print("Error in fetching request: \(error)")
        }
        tableView.reloadData()
    }

}

//MARK: - Table View Data Source

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
}

//MARK: - Table View Delegate Methods

extension CategoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            nsContext.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveCategories()
        }
    }
}
