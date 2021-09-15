# Ultima Online - Journal

An external Journal viewer for Ultima Online.\
Only compatible with the [ClassicUO](https://www.classicuo.eu/) client.\
Works on Windows, Mac and Linux.

Create tabs and filters by using simple regex.\
Comes with pre-configured tabs for:

* All messages
* System messages
* Party messages _(with sound)_
* Mentions _(with sound)_

### **How to use**
---
* Make sure "Save Journal to file in game folder" is enabled in ClassicUO'
	* _(it's in Options under "Speech")_
* Download latest release
* Extract downloaded archive anywhere
* Start `uojournal`
* Select your ClassicUO folder

When no `settings.json` file exists; a new one will be generated, and you will be asked for your ClassicUO path again.\
If you are playing on Outlands; the correct path will be `"/Outlands/ClassicUO/"`

Edit `"settings.json"` to create your own tabs and filters.

### **How does this work?**
---
The viewer will use the latest external journal log found in `"/ClassicUO/Data/Client/JournalLogs/"` and match each line against your configured filters.\
Names are also gathered from the `"/ClassicUO/Data/Profiles/lastcharacter.json"` file at start.