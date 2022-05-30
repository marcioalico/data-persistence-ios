//
//  ViewController.swift
//  core-data-realm
//
//  Created by Marcio Alico on 5/25/22.
//

import UIKit

private let kTodoCellIdentifier = "SBTableViewCell"
private let kDefaultTodoListArray = "TodoListArray"
private let kItemsPlist = "Items.plist"
private let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first?.appendingPathComponent(kItemsPlist)

class TodoListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var todosArray: [TodoItem?] = []
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Items.Plist file path:
        print(dataFilePath)
        
        getItems()
    }
    
    internal func getItems() {
        guard let data =  try? Data(contentsOf: dataFilePath!) else { return }
        let decoder = PropertyListDecoder()
        do {
            todosArray = try decoder.decode([TodoItem].self, from: data)
            self.reloadTableView()
        } catch {
            print("Error during decoding todo items: \(error)")
        }
    }
    
    internal func reloadTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: kTodoCellIdentifier)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add new task", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Save", style: .default) { action in
            let item = TodoItem(title: alertTextField.text!, done: false)
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(todosArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array \(error)")
        }
        
        self.reloadTableView()
    }
}

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
              var item = todosArray[indexPath.row] else { return }
        item.done = !item.done
        cell.accessoryType = item.done ? .checkmark : .none
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

