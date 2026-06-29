//
//  TaskModel.swift
//  iosApp4
//
//  Created by Zubia Tahseen on 2026-06-29.
//

import Foundation

// MARK: - Priority Levels
/// Represents the urgency level of a task, used for sorting and visual indicators
enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { rawValue }
    
    /// SF Symbol icon for each priority level
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "equal.circle"
        case .high: return "exclamationmark.circle"
        }
    }
    
    /// Color name associated with each priority for visual distinction
    var colorName: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

// MARK: - Task Categories
/// Predefined categories to organize tasks into logical groups
enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health"
    case education = "Education"
    
    var id: String { rawValue }
    
    /// SF Symbol icon representing each category
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        }
    }
}

// MARK: - Task Model
/// The main data model representing a single task in the task manager.
/// Conforms to Identifiable for use in SwiftUI lists and Codable for persistence.
struct TaskItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var category: TaskCategory
    var priority: Priority
    var dueDate: Date
    var isCompleted: Bool
    var createdAt: Date
    
    /// Returns true if the task's due date has passed and it is not yet completed
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
}
