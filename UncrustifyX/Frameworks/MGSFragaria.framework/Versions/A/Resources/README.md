#What is it?
Fragaria is an OS X Cocoa syntax colouring NSTextView implemented within a framework named MGSFragaria. It supports a wide range of programming languages and includes preference panel support.

The MGSFragaria framework now properly supports both traditional reference counting memory management and garbage collection.

#Where can I see it in use

You can see Fragaria used in the following products:

* [KosmicTask](http://www.mugginsoft.com) : a multi (20+) language  scripting environment for OS X that features script editing, network sharing, remote execution, and file processing.

If you use MGSFragaria in your app and want it added to the list raise it as an issue.

#Features

Most features are accessed via the framework preferences.

* Configurable syntax colouring
* Configurable font type, size and colour.
* Invisible character display
* Line numbering
* Brace matching and auto insertion
* Page guide
* Simple word auto complete
* Tab and indent control
* Line wrapping


##How do I use it?

The best way to learn how to use the framework is to look at the sample apps.

* __Fragaria__ : a simple editor window that features language selection, a wired up text menu and a preferences panel.

* __Fragaria GC__ : a GC version of the above.

* __Fragaria Doc__ : a simple NSDocument based editor.

##Show me code

A Fragaria view is embedded in a content view.

	#import "MGSFragaria/MGSFragaria.h"

	// we need a container view to host Fragaria in
	NSView *containerView = nil; // loaded from nib or otherwise created

	// create our instance
	MGSFragaria *fragaria = [[MGSFragaria alloc] init];

	// we want to be the delegate
	[fragaria setObject:self forKey:MGSFODelegate];

	// Objective-C is the place e to be
	[self setSyntaxDefinition:@"Objective-C"];

	// embed in our container - exception thrown if containerView is nil
	[fragaria embedInView:containerView];

	// set initial text
	[fragaria setString:@"// We don't need the future."];

The initial appearance of a Fragaria view is determined by the framework preferences controller. The MGSFragaria framework supplies two preference view controllers whose views can be embedded in your preference panel.

    MGSFragariaTextEditingPrefsViewController * textEditingPrefsViewController = [MGSFragariaPreferences sharedInstance].textEditingPrefsViewController;

    MGSFragariaFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController = [MGSFragariaPreferences sharedInstance].fontsAndColoursPrefsViewController;

##Setting preferences

Preference strings are defined in MGSFragaria/MGSFragariaPreferences.h. Each preference name is prefixed with Fragaria for easy identification within the application preferences file.

	// default to line wrap off
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsLineWrapNewDocuments];

All preferences are observed and instances of Fragaria views update immediately to reflect the new preference.

##Where did it come from?
Fragaria started out as the vital pulp of Smultron, now called Fraise. If you want to add additional features to Fragaria then looking at the [Fraise](https://github.com/jfmoy/Fraise) and other forked sources is a good place to start. Fraise is a GC only app so you will need to consider memory management issues when importing code into Fragaria.



 
