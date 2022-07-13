//
//  ViewController.swift
//  core-data-realm
//
//  Created by Marcio Alico on 5/25/22.
//

import UIKit
import CoreData

private let kTodoCellIdentifier = "TodoTableViewCell"
private let kDefaultTodoListArray = "TodoListArray"

// MARK: - CoreData .sqlite path
//private let kItemsPlist = "Items.plist"
//private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(kItemsPlist)

// MARK: - CoreData .sqlite path
private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

class TodoListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var todosArray: [TodoItem?] = []
    var category: Category? {
        didSet {
            getItems()
        }
    }
    
    //let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(dataFilePath)
        
        setUpDelegates()
        getItems()
    }
    
    internal func setUpDelegates() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: kTodoCellIdentifier)
    }
    
    internal func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add new task", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Save", style: .default) { action in
            let item = TodoItem(context: self.context)
            item.title = alertTextField.text
            item.done = false
            item.category = self.category
            self.todosArray.append(item)
            self.saveItems()
        }
        
        alert.addTextField { textField in
            textField.placeholder = "What you need to do?"
            alertTextField = textField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func saveItems() {
        // MARK: - Plist Codable / Decodable persistance (replaced by CoreData)
        //let encoder = PropertyListEncoder()
        //let data = try encoder.encode(todosArray)
        //try data.write(to: dataFilePath!)
        do {
            try self.context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.reloadTableView()
    }
    
    fileprivate func getItems(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "category.name MATCHES %@", category!.name!)
        
        if let paramPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate ,paramPredicate])
            
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }

        do {
            todosArray = try context.fetch(request)
            self.reloadTableView()
        } catch {
            print("Error during decoding todo items: \(error)")
        }
        // MARK: - Plist Codable / Decodable persistance (replaced by CoreData)
        //guard let data =  try? Data(contentsOf: dataFilePath!) else { return }
        //let decoder = PropertyListDecoder()
        //todosArray = try decoder.decode([TodoItem].self, from: data)
    }
}

// MARK: - TableView Delegate & DataSource
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todosArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kTodoCellIdentifier, for: indexPath) as? TodoTableViewCell,
           let item = todosArray[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
              let item = todosArray[indexPath.row] else { return }
        cell.accessoryType = item.done ? .checkmark : .none
        todosArray[indexPath.row]?.done = !item.done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SearchBar Delegate
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchBarText = searchBar.text,
              searchBarText != "" else { return }
        
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        let searchBarPredicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        request.predicate = searchBarPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        getItems(with: request,predicate: searchBarPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, text.count == 0 else { return }
        self.getItems()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

