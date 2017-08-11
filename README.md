# Leaf List

## To Do

* Make parent task in detail view part of the details view table, not the task view table (cleaner API this way, too!)
    * need to make container view resize to height of table view
* Add 'Completed on <DATE>' to details view if task is completed
* Add search option
* Use text view for name field in details view to support multiple lines
* Design app icon
* add some color to the UI
* option to color code tasks (box to left of task name label, option to set image?)

## Completed

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