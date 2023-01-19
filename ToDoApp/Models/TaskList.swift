//
//  TaskList.swift
//  ToDoApp
//
//  Created by Nikolai Maksimov on 18.01.2023.
//

import Foundation


struct TaskList: Hashable {
    var name: String
    var tasks: [Task]
    var identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func testData() -> [TaskList] {
        [
            TaskList(name: "Фильмы", tasks: [Task(name: "22 Пули - Бесмертный", note: "боевик", category: .current),
                                                     Task(name: "Гарри Поттер", note: "2 часть", category: .current),
                                                     Task(name: "Мисте Бин", note: "комедия", category: .completed)]),
            TaskList(name: "Работа", tasks: [Task(name: "Допилить приложение", note: "", category: .completed),
                                                     Task(name: "Получить офер", note: "х2", category: .current)]),
            TaskList(name: "Запчасти на авто", tasks: [Task(name: "Шаровые", note: "2 шт.", category: .completed),
                                                     Task(name: "Подшипник ступичный", note: "левый", category: .current)]),
            TaskList(name: "Дни рождения", tasks: [Task(name: "Маша", note: "2 февраля", category: .completed),
                                                   Task(name: "Валя", note: "30 октября", category: .completed),
                                                     Task(name: "Даша", note: "17 июня", category: .current)]),
        ]
    }
}

struct Task: Hashable {
    var name: String
    var note: String
    var category: TaskCategory
    var identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
