//
//  TasksViewController.swift
//  ToDoApp
//
//  Created by Nikolai Maksimov on 19.01.2023.
//

import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func updateModel(upgradeTask: TaskList, indexPath: IndexPath)
}

final class TasksViewController: UIViewController {
    
    var task: TaskList!
    var indexPath: IndexPath?
    
    weak var delegate: TasksViewControllerDelegate?
    
    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<TaskCategory, Task>!
    
    // MARK: - LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        configureDataSource()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        getUpdatesData()
    }
    
    // Navigation Bar configure
    private func configureNavigationBar() {
        navigationItem.title = "Tasks"
        navigationController?.navigationBar.prefersLargeTitles = true
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditState))
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addNewElement))
        navigationItem.rightBarButtonItems = [editButton, addButton]
    }
    
    // TableView Configuration
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    @objc private func addNewElement() {
        showAlert()
    }
    
    @objc  private func toggleEditState() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    // Data Source Configure
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, task in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = task.name
            content.secondaryText = task.note
            cell.contentConfiguration = content
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<TaskCategory, Task>()
        for category in TaskCategory.allCases {
            let items = task.tasks.filter { $0.category == category }
            snapshot.appendSections([category])
            snapshot.appendItems(items)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func getUpdatesData() {
        let snapshot = dataSource.snapshot()
        let tasks = snapshot.itemIdentifiers
        let newTask = TaskList(name: task.name, tasks: tasks)
        dataSource.apply(snapshot, animatingDifferences: true)
        delegate?.updateModel(upgradeTask: newTask, indexPath: indexPath!)
    }
}

// MARK: - AlertController - добавляет новый список
extension TasksViewController {
    private func showAlert() {
        let alert = UIAlertController(title: "New Task", message: "Enter a name for the new task list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let nameTask = alert.textFields?.first?.text else { return }
            guard let noteTask = alert.textFields?.last?.text else { return }
            guard !nameTask.isEmpty else { return }
            
            let newTasks = Task(name: nameTask, note: noteTask, category: .current)
            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems([newTasks], toSection: .current)
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField { tf in
            tf.placeholder = "Task"
        }
        alert.addTextField { tf in
            tf.placeholder = "Note"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var snapshot = dataSource.snapshot()
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            if let item = self.dataSource.itemIdentifier(for: indexPath) {
                snapshot.deleteItems([item])
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            isDone(true)
        }
        
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [self] _, _, isDone in
            guard var sourceItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
            
            if sourceItem.category == .completed {
                snapshot.deleteItems([sourceItem])
                sourceItem.category = .current
                snapshot.appendItems([sourceItem], toSection: .current)
            } else if sourceItem.category == .current {
                snapshot.deleteItems([sourceItem])
                sourceItem.category = .completed
                snapshot.appendItems([sourceItem], toSection: .completed)
            }
            dataSource.defaultRowAnimation = .left
            dataSource.apply(snapshot, animatingDifferences: true)
            isDone(true)
        }
        editAction.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        
        switch section {
        case 0:
            label.text = "Current"
        default:
            label.text = "Completed"
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}
