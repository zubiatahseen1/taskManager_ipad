//
//  TaskStore.swift
//  iosApp4
//
//  Created by Zubia Tahseen on 2026-06-29.
//

import Foundation
import SwiftUI

// MARK: - Task Store
/// Observable class that manages the collection of tasks.
/// Handles CRUD operations and persists data to UserDefaults so tasks survive app restarts.
@Observable
class TaskStore {
    
    /// The main array holding all tasks in the app
    var tasks: [TaskItem] = [] {
        didSet {
            // Automatically save tasks whenever the array changes
            saveTasks()
        }
    }
    
    /// UserDefaults key used for storing encoded task data
    private let storageKey = "savedTasks"
    
    // MARK: - Initialization
    /// Loads any previously saved tasks from UserDefaults on launch
    init() {
        loadTasks()
    }
    
    // MARK: - CRUD Operations
    
    /// Adds a new task to the store
    /// - Parameter task: The TaskItem to add
    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }
    
    /// Updates an existing task by matching its ID
    /// - Parameter task: The updated TaskItem (must have the same ID as an existing task)
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    /// Removes tasks at the specified index positions
    /// - Parameter offsets: The IndexSet of positions to remove
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    /// Toggles the completion status of a task
    /// - Parameter task: The task whose completion status should be toggled
    func toggleCompletion(for task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    // MARK: - Filtering Helpers
    
    /// Returns tasks filtered by a specific category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of tasks matching the given category
    func tasks(for category: TaskCategory) -> [TaskItem] {
        tasks.filter { $0.category == category }
    }
    
    /// Returns only tasks that have not been completed
    var pendingTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }
    
    /// Returns only tasks that have been marked as completed
    var completedTasks: [TaskItem] {
        tasks.filter { $0.isCompleted }
    }
    
    /// Returns tasks that are past their due date and not yet completed
    var overdueTasks: [TaskItem] {
        tasks.filter { $0.isOverdue }
    }
    
    // MARK: - Persistence
    
    /// Encodes the tasks array to JSON and saves it to UserDefaults
    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    /// Loads and decodes tasks from UserDefaults; populates sample data if no saved tasks exist
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        } else {
            // Load sample data for first-time users so the app isn't empty
            loadSampleData()
        }
    }
    
    // MARK: - Sample Data
    /// Provides initial sample tasks so the app has content on first launch
    private func loadSampleData() {
        let calendar = Calendar.current
        tasks = [
            TaskItem(
                title: "Finish iOS Assignment",
                description: "Complete the iPad task manager app for the weekly assignment. Make sure to add comments and push to GitHub.",
                category: .education,
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                isCompleted: false,
                createdAt: Date()
            ),
            TaskItem(
                title: "Buy Groceries",
                description: "Pick up fruits, vegetables, milk, and bread from the store.",
                category: .shopping,
                priority: .medium,
                dueDate: calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                isCompleted: false,
                createdAt: Date()
            ),
            TaskItem(
                title: "Team Meeting",
                description: "Attend the weekly standup meeting with the development team at 10 AM.",
                category: .work,
                priority: .high,
                dueDate: calendar.date(byAdding: .hour, value: 3, to: Date()) ?? Date(),
                isCompleted: false,
                createdAt: Date()
            ),
            TaskItem(
                title: "Morning Run",
                description: "Go for a 30-minute jog around the park.",
                category: .health,
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                isCompleted: true,
                createdAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            TaskItem(
                title: "Read Swift Documentation",
                description: "Review the latest SwiftUI documentation on NavigationSplitView and Observable.",
                category: .education,
                priority: .medium,
                dueDate: calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                isCompleted: false,
                createdAt: Date()
            ),
            TaskItem(
                title: "Update Resume",
                description: "Add recent projects and skills to the resume document.",
                category: .personal,
                priority: .medium,
                dueDate: calendar.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                isCompleted: false,
                createdAt: Date()
            )
        ]
    }
}
