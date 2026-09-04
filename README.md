# iosApp4 — iPad Task Manager

A SwiftUI task manager built for iPad, using a three-column `NavigationSplitView` layout (sidebar → task list → detail pane). Created as a school assignment for the Mobile and Web Developer program at Trios College.

## Features

- **Full CRUD** — create, view, update, complete, and delete tasks
- **Three-column iPad layout** — sidebar navigation, filtered task list, and a detail pane side by side
- **Categories** — Work, Personal, Shopping, Health, and Education, each with its own SF Symbol icon and live task count
- **Priority levels** — Low, Medium, and High, with color-coded indicators (green / orange / red)
- **Smart filters** — All Tasks, Overdue, and Completed views in the sidebar
- **Search** — filter the visible task list by title
- **Automatic sorting** — tasks sort by priority first (high to low), then by due date (earliest first)
- **Overdue detection** — incomplete tasks past their due date are highlighted in red
- **Persistence** — tasks are encoded to JSON and saved to `UserDefaults`, so they survive app restarts
- **Sample data** — six starter tasks load on first launch so the app isn't empty

## Screens

| View | Purpose |
| --- | --- |
| `ContentView` | Root three-column split view with sidebar, task list, and detail pane |
| `AddTaskView` | Modal form sheet for creating a task (title, description, category, priority, due date) |
| `TaskDetailView` | Full task details with a header card, 2×2 info grid, description, and action buttons |

## Project Structure

```
iosApp4/
├── iosApp4App.swift      # App entry point
├── ContentView.swift     # Root split view, sidebar, task list, and TaskRowView
├── AddTaskView.swift     # Form sheet for creating new tasks
├── TaskDetailView.swift  # Detail pane for a selected task
├── TaskModel.swift       # TaskItem model, Priority and TaskCategory enums
└── TaskStore.swift       # Observable store — CRUD, filtering, and persistence
```

## Architecture

The app follows a simple MVVM-style split:

- **Model** — `TaskItem` is a `Codable`, `Identifiable` struct holding the title, description, category, priority, due date, completion flag, and creation date. It exposes a computed `isOverdue` property.
- **Store** — `TaskStore` is marked `@Observable` (the Swift 5.9+ observation macro). It owns the `tasks` array, exposes CRUD methods and filtering helpers (`pendingTasks`, `completedTasks`, `overdueTasks`, `tasks(for:)`), and auto-saves via a `didSet` observer on the array.
- **Views** — SwiftUI views read the store directly and stay free of business logic.

## Tech Stack

- Swift 5 / SwiftUI
- `@Observable` for state management
- `UserDefaults` + `JSONEncoder` / `JSONDecoder` for persistence
- SF Symbols for iconography
- `ContentUnavailableView` for empty states

## Requirements

- Xcode 26 or later
- iOS 26.4+ (universal — iPhone and iPad, though the layout is designed for iPad)

## Getting Started

```bash
git clone https://github.com/zubiatahseen1/iosApp4.git
cd iosApp4
open iosApp4.xcodeproj
```

Select an iPad simulator in Xcode and press ⌘R to run.

## Author

Zubia Tahseen — [@zubiatahseen1](https://github.com/zubiatahseen1)
