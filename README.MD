# Ultima Online - Journal

An external Journal viewer for Ultima Online.\
Perfect for your secondary monitor, or for playing notification sounds for certain messages.


Create tabs and filters by using [Perl regular expressions](https://perldoc.perl.org/perlre).\
Comes with pre-configured tabs for:

* All messages
* System messages
* Party messages _(with sound)_
* Mentions _(with sound)_

Only compatible with the [ClassicUO](https://www.classicuo.eu/) client.\
Works on Windows, Mac and Linux.

### **How to use**
---
First, make sure **"Save Journal to file in game folder"** is enabled in ClassicUO.\
_(it's in Options under **"Speech"**)_


* From GitHub release
	* Download latest uojournal release
	* Extract downloaded archive anywhere
* From source
	* Download [BlitzMax NG](https://blitzmax.org/)
	* Git clone this repo
	* Build **"uojournal.bmx"** as GUI application
* Start **"uojournal"**
* Select your ClassicUO folder

When no **"settings.json"** file exists; a new one will be generated, and you will be asked for your ClassicUO path again.\
If you are playing on Outlands; the correct path will be **"/Outlands/ClassicUO/"**

Edit **"settings.json"** to create your own tabs and filters.

### **How does this work?**
---
The viewer will use the latest external journal log found in **"/ClassicUO/Data/Client/JournalLogs/"** and match each line against your **"settings.json"** filters.\
Names are also gathered from the **"/ClassicUO/Data/Profiles/lastcharacter.json"** file at start.