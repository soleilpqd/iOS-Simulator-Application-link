iOS-Simulator-Application-link
==============================

Command line tool to create shortcut (symbolic link) to application folders of XCode 6 simulators.

Tested on Mac OS X 10.10.1 Yosemite with XCode 6.1.1.

###Install###

After build project, copy the "iSimApp" binary to:
- /usr/bin or /usr/local/bin: need administrator privilege. Then we can use single <code>iSimApp</code> in Terminal.
- Any folder you want, but we have to use full path to iSimApp in Terminal. Eg: copy to home folder and use <code>~/iSimApp</code> in Terminal.

###Usage###

- Create a target folder to store shortcuts.
- In Terminal:
```
iSimApp --map <path to target folder>
```
Same as
```
cd <path to target foler>
iSimApp --map
```

###Use in Finder###

This comes with **iSimApp.app** - a simple Automator app - which helps running <code>iSimApp</code> in Finder.
- <code>Show package contents</code> of **iSimApp.app**, copy & paste the <code>iSimApp</code> binary inside (just next to Contents folder) (**iSimApp.app** alreay contains my latest build).
- Place the **iSimApp.app** inside target folder. Run (double click) **iSimApp.app** to create or update shortcuts to Simulator apps.
