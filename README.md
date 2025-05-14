# 📱 ToDo App (iOS - Objective-C)

A simple and functional ToDo list iOS application built with **Objective-C** and **Storyboards**. Tasks are categorized by status (`To Do`, `In Progress`, `Done`) and priority (`Low`, `Medium`, `High`). Users can add, edit, delete, sort, and manage tasks with a clean and intuitive interface.

---

## 🚀 Features

- ✅ Add new tasks with title, description, priority, and status
- ✏️ Edit existing tasks
- 🗑 Delete tasks with confirmation alert
- 🔀 Toggle sorting by priority (Low, Medium, High)
- 📂 Organized task display by:
  - **Status**: To Do, In Progress, Done
  - **Priority** (when sorting is enabled)
- 💾 Data persistence using `NSUserDefaults`
- 🧭 Smooth navigation between status screens using `UITabBarController`
- 🧱 Built using MVC architecture and Storyboards

---

## 📸 Screenrecording



https://github.com/user-attachments/assets/e319dc73-cf1d-4cfa-85c9-ff672104e60d





---

## 🛠 Technologies Used

- Programming Language: **Objective-C**
- UI: **Storyboard**, **AutoLayout**
- Data Persistence: **NSUserDefaults**
- Architecture: **MVC**
- Device Support: **iPhone only** (can be expanded)

---

## 📂 Project Structure


ToDoApp/
├── Models/
│ └── Task.h / Task.m
├── Controllers/
│ ├── TodoTableViewController
│ ├── InProgressTableViewController
│ ├── DoneTableViewController
│ └── AddEditTaskViewController
├── Views/
│ └── Custom section headers, cells
├── Utils/
│ └── DataManager for NSUserDefaults handling
├── Main.storyboard
└── AppDelegate / SceneDelegate

---

## 📝 How Data Is Stored

- All tasks are stored as dictionaries inside an array.
- These arrays are split into three based on task status:
  - `To Do`
  - `In Progress`
  - `Done`
- These are stored as a single master array in **NSUserDefaults** with a predefined key.
- Data is retrieved and filtered per view controller.

---

## 📦 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/todo-ios-objc.git
