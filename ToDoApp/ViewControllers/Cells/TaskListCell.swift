//
//  TaskListCell.swift
//  ToDoApp
//
//  Created by Nikolai Maksimov on 18.01.2023.
//

import UIKit

final class TaskListCell: UITableViewCell {
    
    static let identifier = "TaskListCell"
    
    // MARK: - Private properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - LifeCycle methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(taskList: TaskList) {
        titleLabel.text = taskList.name
        let currentTasks = taskList.tasks.filter { $0.category == .current }
        
        if taskList.tasks.isEmpty {
            taskCountLabel.text = "0"
            accessoryType = .none
        } else if currentTasks.isEmpty {
            taskCountLabel.text = nil
            accessoryType = .checkmark
        } else {
            taskCountLabel.text = "\(currentTasks.count)"
            accessoryType = .none
        }
    }
}

// MARK: - views & constraints
extension TaskListCell {
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(taskCountLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: taskCountLabel.leadingAnchor, constant: 5),
        ])
        
        NSLayoutConstraint.activate([
            taskCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            taskCountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            taskCountLabel.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
}
