//
//  Category.swift
//  ToDoApp
//
//  Created by Nikolai Maksimov on 18.01.2023.
//

import Foundation


enum TaskListCategory: String, CaseIterable {
    case main = ""
}

enum TaskCategory: String, CaseIterable {
    case current = "Текущие"
    case completed = "Выполненные"
}
