# To Do

## To Do

* define data model
    * define in JSON (or some standard format i.e. XML) and make it easily exportable for migration
* Use firebase for backend
* Create branch to: Split group into separate type: no longer same as task, more like a "tag" (or "group" is a good name)
* bug: moving tasks does not update data model and is therefore not persistant
* Move notes and date created to a separate view exposed by a detail disclosure in the top right nav bar
* Bug: tasks with long names that extend past two lines in the table view cell get cut off
* Add red exclamation point, highlight task red when it gets older than set amount of time (one work, for example)
* Add task dependencies
* Show chain of tasks in task details
* Add ability to move task to be a subtask
* Use text view for name field in details view to support multiple lines
* option to color code tasks (box to left of task name label, option to set image?)
* Fix bug: after searching the offset for the nav bar is doubled and the search bar can't be hidden

## Completed

* Bug: can't edit notes once text has been added - add an edit button in nav bar
* Change bar button tint color to green (?)
* add some color to the UI
* Design app icon
* Make tasks movable again
* When deleting a task with sub tasks show a pop up alert to confirm
* When deleting a task with sub tasks delete all the subtasks
* Add search option
* Add 'Completed on <DATE>' to details view if task is completed
* Scroll the task table down when adding a new task
* Build real Details View with two table view: one static and one dynamic
* Add "trash" view
* add "completed" view
* Fix crash in trash view
* enable hyperlinks in notes (add a webview?)
* Add ability to reorder tasks
* Add option to restore tasks in trash
* Fix tasks view
* Bug: when clicking for the details of a completed task the checkbox button unchecks itself
* Move completed task to end of list, set priority lower than the lowest uncomplete task and higher than the highest completed
* Show date task was deleted in trash view
* Make name field in details view an editable text field
* Add option to empty trash
* Hide completed button in trash view
* Show parent task in detail view of a task in the tasks tab
* Make parent task in detail view part of the details view table, not the task view table (cleaner API this way, too!)
    * need to make container view resize to height of table view
* Fix crash case when moving task in details view with keyboard shown and the entire visible table is filled

## Stretch Goals

* iCloud integration
* Desktop app
* Web app (possible with iCloud?)
* Rich text editor with drawing and images (camera, camera roll) in notes view
* Create a widget?
* Load data from xml? (debugging)
* Add completed view that sorts by date as sections to see daily progress
* option to export data as xml and send to email
* Clean up task drag-and-drop appearance
* Subclass UITextView to add placeholder test
* Add option to move a task to a different group
