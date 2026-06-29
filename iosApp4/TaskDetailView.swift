//
//  TaskDetailView.swift
//  iosApp4
//
//  Created by Zubia Tahseen on 2026-06-29.
//
//  Displays the full details of a selected task in the detail pane.
//  Allows the user to toggle completion and delete the task.
//

import SwiftUI

// MARK: - Task Detail View
/// Shows comprehensive information about a single task, including its title,
/// description, priority badge, category, due date, and creation date.
/// Provides actions to mark as complete or delete the task.
struct TaskDetailView: View {
    
    /// The task to display details for
    let task: TaskItem
    
    /// Reference to the task store for performing actions (toggle, delete)
    let store: TaskStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header Card
                // Displays the task title, completion status, and priority badge
                headerCard
                
                // MARK: - Info Cards
                // Grid of cards showing category, priority, due date, and creation date
                infoGrid
                
                // MARK: - Description
                // Shows the task description if one was provided
                if !task.description.isEmpty {
                    descriptionSection
                }
                
                // MARK: - Action Buttons
                actionButtons
            }
            .padding(24)
        }
        .navigationTitle("Task Details")
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Header Card
    /// A prominent card at the top showing the task title and status
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status indicator row
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.seal.fill" : "clock.fill")
                    .foregroundStyle(task.isCompleted ? .green : .orange)
                Text(task.isCompleted ? "Completed" : "In Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(task.isCompleted ? .green : .orange)
                
                Spacer()
                
                // Overdue badge if applicable
                if task.isOverdue {
                    Text("OVERDUE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red, in: Capsule())
                }
            }
            
            // Task title
            Text(task.title)
                .font(.title)
                .fontWeight(.bold)
                .strikethrough(task.isCompleted)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Info Grid
    /// A 2x2 grid of informational cards showing task metadata
    private var infoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            // Category card
            InfoCard(
                icon: task.category.icon,
                title: "Category",
                value: task.category.rawValue,
                color: .blue
            )
            
            // Priority card with dynamic color
            InfoCard(
                icon: task.priority.icon,
                title: "Priority",
                value: task.priority.rawValue,
                color: priorityColor
            )
            
            // Due date card with overdue highlighting
            InfoCard(
                icon: "calendar",
                title: "Due Date",
                value: task.dueDate.formatted(date: .abbreviated, time: .shortened),
                color: task.isOverdue ? .red : .purple
            )
            
            // Creation date card
            InfoCard(
                icon: "clock.arrow.circlepath",
                title: "Created",
                value: task.createdAt.formatted(date: .abbreviated, time: .omitted),
                color: .gray
            )
        }
    }
    
    // MARK: - Description Section
    /// Displays the task's description text in a styled card
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(task.description)
                .font(.body)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Action Buttons
    /// Provides buttons to toggle completion status and delete the task
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Toggle completion button
            Button {
                store.toggleCompletion(for: task)
            } label: {
                Label(
                    task.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                    systemImage: task.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(task.isCompleted ? Color.orange : Color.green, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            
            // Delete button
            Button(role: .destructive) {
                if let index = store.tasks.firstIndex(where: { $0.id == task.id }) {
                    store.tasks.remove(at: index)
                }
            } label: {
                Label("Delete Task", systemImage: "trash")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.red)
            }
        }
    }
    
    /// Returns the appropriate color for the task's priority level
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Info Card
/// A reusable card component that displays a labeled piece of information
/// with an icon, title, value, and accent color.
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon with colored background circle
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .padding(8)
                .background(color.opacity(0.1), in: Circle())
            
            // Label and value
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TaskDetailView(
            task: TaskItem(
                title: "Sample Task",
                description: "This is a sample task to preview the detail view layout.",
                category: .work,
                priority: .high,
                dueDate: Date(),
                isCompleted: false,
                createdAt: Date()
            ),
            store: TaskStore()
        )
    }
}
