//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Nikolai Maksimov on 18.01.2023.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: Private properties
    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<TaskListCategory, TaskList>!
        
    // MARK: - LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        configureDataSource()
    }
}

// MARK: - TableView Configuration
extension TaskListViewController {
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.identifier)
        view.addSubview(tableView)
    }
}

// MARK: - DATA SOURCE Configure
extension TaskListViewController {
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, taskList in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.identifier, for: indexPath) as? TaskListCell else { return UITableViewCell() }
            
            cell.configure(taskList: taskList)
            return cell
        })
        var snapshot = NSDiffableDataSourceSnapshot<TaskListCategory, TaskList>()
        let tasks = TaskList.testData()
        snapshot.appendSections([.main])
        snapshot.appendItems(tasks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                let task = dataSource.itemIdentifier(for: indexPath)
                let tasksVC = TasksViewController()
                tasksVC.delegate = self
                tasksVC.indexPath = indexPath
                tasksVC.task = task
                navigationController?.pushViewController(tasksVC, animated: true)
    }
    
    // UISwipeActionsConfiguration
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            if let item = self.dataSource.itemIdentifier(for: indexPath) {
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteItems([item])
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.editTaskList(indexPath: indexPath)
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            guard let taskList = self.dataSource.itemIdentifier(for: indexPath) else { return }
            var completedTasks: [Task] = []
            
            for task in taskList.tasks {
                let completedAllTasks = Task(name: task.name, note: task.note, category: .completed)
                completedTasks.append(completedAllTasks)
            }
            
            var snapshot = self.dataSource.snapshot()
            let newTask = TaskList(name: taskList.name, tasks: completedTasks)
            snapshot.insertItems([newTask], afterItem: taskList)
            snapshot.deleteItems([taskList])
            
            self.dataSource.defaultRowAnimation = .fade
            self.dataSource.apply(snapshot, animatingDifferences: true)
            
            isDone(true)
        }
        editAction.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Edit List Alert Controller
extension TaskListViewController {
    private func editTaskList(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit List", message: "Please set title for new task list", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        guard let taskList = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let saveAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let textField = alert.textFields?.first else { return }
            guard let text = textField.text, !text.isEmpty else { return }
            
            var updateTaskList = taskList
            updateTaskList.name = text
            
            var snapshot = self.dataSource.snapshot()
            snapshot.insertItems([updateTaskList], beforeItem: taskList)
            snapshot.deleteItems([taskList])
            
            self.dataSource.defaultRowAnimation = .fade
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { tf in
            tf.placeholder = "List Name"
            tf.text = taskList.name
        }
        present(alert, animated: true)
    }
}

// MARK: - TasksViewControllerDelegate
extension TaskListViewController: TasksViewControllerDelegate {
    func updateModel(upgradeTask: TaskList, indexPath: IndexPath) {
        guard let sourceItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.insertItems([upgradeTask], beforeItem: sourceItem)
        snapshot.deleteItems([sourceItem])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Navigation Bar configure
extension TaskListViewController {
    private func configureNavigationBar() {
        navigationItem.title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 194/255)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(toggleEditState))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewElement))
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func toggleEditState() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @objc private func addNewElement() {
        addNewTaskList()
    }
    
   // New List Alert Controller
    private func addNewTaskList() {
        let alert = UIAlertController(title: "New List", message: "Please set title for new task list", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let textField = alert.textFields?.first else { return }
            guard let text = textField.text, !text.isEmpty else { return }
            var snapshot = self.dataSource.snapshot()
            let taskList = TaskList(name: text, tasks: [])
            snapshot.appendItems([taskList])
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { tf in
            tf.placeholder = "List Name"
        }
        present(alert, animated: true)
    }
}
