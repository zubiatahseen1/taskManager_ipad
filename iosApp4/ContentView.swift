//
//  ContentView.swift
//  iosApp4
//
//  Created by Zubia Tahseen on 2026-06-29.
//
//  Main view of the iPad Task Manager app.
//  Uses NavigationSplitView to provide a sidebar + detail layout
//  optimized for the iPad's larger screen.
//

import SwiftUI

// MARK: - Sidebar Filter Options
/// Represents the different filter options available in the sidebar navigation.
/// Each filter shows a different subset of tasks in the main list.
enum SidebarFilter: Hashable {
    case all                        // Show all tasks
    case category(TaskCategory)     // Filter by a specific category
    case completed                  // Show only completed tasks
    case overdue                    // Show only overdue tasks
}

// MARK: - Content View
/// The root view of the app, using a three-column NavigationSplitView
/// that provides sidebar navigation, a task list, and a detail pane — ideal for iPad.
struct ContentView: View {
    
    /// The shared task store that manages all task data
    @State private var store = TaskStore()
    
    /// Tracks which sidebar filter is currently selected
    @State private var selectedFilter: SidebarFilter? = .all
    
    /// Tracks which task is selected in the list for detail display
    @State private var selectedTask: TaskItem?
    
    /// Controls whether the Add Task sheet is presented
    @State private var showingAddTask = false
    
    /// Controls the search text for filtering tasks by title
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            // MARK: Sidebar Column
            // The sidebar provides category-based navigation and quick filters
            sidebarView
        } content: {
            // MARK: Task List Column
            // Displays tasks based on the selected sidebar filter
            taskListView
        } detail: {
            // MARK: Detail Column
            // Shows full details for the selected task, or a placeholder
            detailView
        }
        .sheet(isPresented: $showingAddTask) {
            // Present the Add Task form as a modal sheet
            AddTaskView(store: store)
        }
    }
    
    // MARK: - Sidebar View
    /// Builds the sidebar with category filters, status filters, and a task summary
    private var sidebarView: some View {
        List(selection: $selectedFilter) {
            // Quick overview section showing task counts
            Section("Overview") {
                Label("All Tasks (\(store.tasks.count))", systemImage: "tray.fill")
                    .tag(SidebarFilter.all)
                
                Label("Overdue (\(store.overdueTasks.count))", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(store.overdueTasks.isEmpty ? Color.primary : Color.red)
                    .tag(SidebarFilter.overdue)
                
                Label("Completed (\(store.completedTasks.count))", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .tag(SidebarFilter.completed)
            }
            
            // Category section — one row per category with task count
            Section("Categories") {
                ForEach(TaskCategory.allCases) { category in
                    Label(
                        "\(category.rawValue) (\(store.tasks(for: category).count))",
                        systemImage: category.icon
                    )
                    .tag(SidebarFilter.category(category))
                }
            }
        }
        .navigationTitle("Task Manager")
        .toolbar {
            // Add Task button in the sidebar toolbar
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
    }
    
    // MARK: - Task List View
    /// Displays a filtered and searchable list of tasks based on the sidebar selection
    private var taskListView: some View {
        Group {
            if filteredTasks.isEmpty {
                // Empty state when no tasks match the current filter
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checklist",
                    description: Text("Tap the + button to add a new task.")
                )
            } else {
                List(selection: $selectedTask) {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task, store: store)
                            .tag(task)
                    }
                    .onDelete { offsets in
                        // Map filtered offsets back to the store's array and delete
                        let tasksToDelete = offsets.map { filteredTasks[$0] }
                        for task in tasksToDelete {
                            if let index = store.tasks.firstIndex(where: { $0.id == task.id }) {
                                store.tasks.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(filterTitle)
        .searchable(text: $searchText, prompt: "Search tasks...")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    // MARK: - Detail View
    /// Shows detailed information for the selected task, or a placeholder if none is selected
    private var detailView: some View {
        Group {
            if let task = selectedTask {
                TaskDetailView(task: task, store: store)
            } else {
                // Placeholder shown when no task is selected in the list
                ContentUnavailableView(
                    "Select a Task",
                    systemImage: "sidebar.right",
                    description: Text("Choose a task from the list to see its details.")
                )
            }
        }
    }
    
    // MARK: - Filtering Logic
    
    /// Returns the display title for the current sidebar filter
    private var filterTitle: String {
        switch selectedFilter {
        case .all, .none:
            return "All Tasks"
        case .category(let cat):
            return cat.rawValue
        case .completed:
            return "Completed"
        case .overdue:
            return "Overdue"
        }
    }
    
    /// Computes the list of tasks to display based on the active filter and search text
    private var filteredTasks: [TaskItem] {
        var result: [TaskItem]
        
        // First filter by sidebar selection
        switch selectedFilter {
        case .all, .none:
            result = store.tasks
        case .category(let cat):
            result = store.tasks(for: cat)
        case .completed:
            result = store.completedTasks
        case .overdue:
            result = store.overdueTasks
        }
        
        // Then apply search text filter on the task title
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sort by priority (high first) then by due date (earliest first)
        return result.sorted {
            if $0.priority != $1.priority {
                return priorityOrder($0.priority) > priorityOrder($1.priority)
            }
            return $0.dueDate < $1.dueDate
        }
    }
    
    /// Maps priority to a numeric value for sorting (higher = more urgent)
    private func priorityOrder(_ priority: Priority) -> Int {
        switch priority {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }
}

// MARK: - Task Row View
/// A single row in the task list, showing the task's title, category, priority, and due date.
/// Includes a button to toggle the task's completion status.
struct TaskRowView: View {
    let task: TaskItem
    let store: TaskStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle button — filled circle when complete
            Button {
                store.toggleCompletion(for: task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Task info: title, category badge, and due date
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)    // Strike through completed tasks
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    // Category label
                    Label(task.category.rawValue, systemImage: task.category.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Due date with overdue highlighting
                    Text(task.dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(task.isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            // Priority indicator icon with corresponding color
            Image(systemName: task.priority.icon)
                .foregroundStyle(priorityColor)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
    
    /// Returns the SwiftUI color matching the task's priority level
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Make TaskItem Hashable for List selection binding
extension TaskItem: Hashable {
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
