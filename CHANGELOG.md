# 0.4.2
## 2013-05-18
- Fix fault that may cause crash on launch after deleting the preferences plist.
- Fix fault with preview code view height being 9px too tall for container
- Documentation panel now shows the union of all the ticked languages, plus all options with no assigned language.
- Update bundled UncrustifyPlugin.xcplugin
- Show bundled plugin version on install button in preferences. Prompt if overwrite will occur.

# 0.4.1
## 2013-04-23
- Fix fault with pasteboard not being cleared after reading contents.

# 0.4
## 2013-04-19
- Contextual-menus on table views.
- Forward-delete key works in addition to back-delete key for removing items from tables.
- Xcode Integration via BBUncrustifyPlugin-Xcode 1.0.2
- Fix fault making it difficult to get first-responder status on text fields in table rows
- Fix fault with window state being incorrectly reflected in the menus
- Tweak behavior for when "remove items" is chosen and multiple items are selected/clicked or a combination
- Updated uncrustify binary
- Allow saving files without .cfg extension
- Default filename is untitled.cfg
- Exporting a file which has been imported will suggest the same filename

# 0.3
## 2013-02-03

- Console window for viewing stdout/stderr from uncrustify binary
- Console Toolbar icon
- Added "Type" column in file input table
- Added +/- buttons adjacent to file input table
- Removed unused "Format" menu
- New "Open Files…" menu item, mapped to ⌘O
- Changed keybinding for importing configuration from ⌘O to ⌘I
- Re-arranged contents of View Menu, and dynamically update text to Show…/Hide… 
- Update uncrustify binary; Add new option `align_keep_extra_space` to definitions