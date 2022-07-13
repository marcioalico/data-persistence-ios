//
//  CategoryTableViewController.swift
//  core-data-realm
//
//  Created by Marcio Alico on 6/18/22.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    private let kCategoryCellIdentifier = "CategoryTableViewCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories: [Category?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarButton()
        getCategories()
    }
    
    fileprivate func setUpBarButton() {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc fileprivate func addCategory() {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add new Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Save", style: .default) { action in
            let item = Category(context: self.context)
            item.name = alertTextField.text
            self.categories.append(item)
            self.saveItems()
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Name a new category"
            alertTextField = textField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryCellIdentifier, for: indexPath) as? CategoryTableViewCell,
           let item = categories[indexPath.row] {
            cell.textLabel?.text = item.name
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let todosVc = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            todosVc.category = categories[indexPath.row]
        }
    }
    
    // MARK: - Data manupilation

    fileprivate func getCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
            self.reloadTableView()
        } catch {
            print("Error during decoding todo items: \(error)")
        }
    }
    
    fileprivate func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.reloadTableView()
    }
    
    // MARK: - Utils
    
    fileprivate func reloadTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: kCategoryCellIdentifier)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}
