//
//  AddTaskView.swift
//  iosApp4
//
//  Created by Zubia Tahseen on 2026-06-29.
//
//  A form-based sheet for creating new tasks.
//  Collects title, description, category, priority, and due date.
//

import SwiftUI

// MARK: - Add Task View
/// Presents a modal form allowing the user to create a new task.
/// Uses SwiftUI Form with grouped sections for a clean, organized input experience.
struct AddTaskView: View {
    
    /// Reference to the shared task store so the new task can be added
    var store: TaskStore
    
    /// Dismiss action to close the sheet after saving or cancelling
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form State
    /// The title of the new task (required)
    @State private var title = ""
    
    /// An optional longer description of the task
    @State private var description = ""
    
    /// The category the task belongs to (defaults to Personal)
    @State private var category: TaskCategory = .personal
    
    /// The urgency level of the task (defaults to Medium)
    @State private var priority: Priority = .medium
    
    /// The deadline for the task (defaults to tomorrow)
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Task Details Section
                Section("Task Details") {
                    // Title text field — the primary identifier of the task
                    TextField("Task Title", text: $title)
                        .font(.headline)
                    
                    // Multi-line description field for additional context
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // MARK: Organization Section
                Section("Organization") {
                    // Category picker — determines which sidebar group the task appears in
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    // Priority picker — affects sorting order and visual indicators
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Label(p.rawValue, systemImage: p.icon)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: Due Date Section
                Section("Due Date") {
                    // Date picker restricted to future dates only
                    DatePicker(
                        "Due Date",
                        selection: $dueDate,
                        in: Date()...,          // Only allow future dates
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // MARK: Preview Section
                // Shows a live preview of the task as it will appear in the list
                Section("Preview") {
                    HStack(spacing: 12) {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title.isEmpty ? "Task Title" : title)
                                .font(.headline)
                                .foregroundStyle(title.isEmpty ? .secondary : .primary)
                            
                            HStack(spacing: 8) {
                                Label(category.rawValue, systemImage: category.icon)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(dueDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: priority.icon)
                            .foregroundStyle(previewPriorityColor)
                            .font(.title3)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button — dismisses the sheet without saving
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save button — creates the task and adds it to the store
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty) // Require at least a title
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Save Action
    /// Creates a new TaskItem from the form fields and adds it to the store
    private func saveTask() {
        let newTask = TaskItem(
            title: title,
            description: description,
            category: category,
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            createdAt: Date()
        )
        store.addTask(newTask)
        dismiss()
    }
    
    /// Returns the color for the priority indicator in the preview section
    private var previewPriorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    AddTaskView(store: TaskStore())
}
