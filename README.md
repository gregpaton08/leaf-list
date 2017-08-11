# Leaf List

## To Do

* Make name field in details view an editable text field (reuse NewTaskTableViewCell?).
* Add option to empty trash
* Hide completed button in trash view
* Show parent task in details view under task tab
* Design app icon
* Add search option
* add some color to the UI
* option to color code tasks (box to left of task name label, option to set image?)
* Add 'Completed on <DATE>' to details view if task is completed
* Subclass UITextView to add placeholder test
* Show parent task in detail view of a task in the tasks tab

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