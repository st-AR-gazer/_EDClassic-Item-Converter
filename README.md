# .EDClassic.Gbx and .Item.Gbx to .Block.Gbx and .Item.Gbx converter

A tool built upon [tm-convert-blocks-to-items](https://github.com/RuurdBijlsma/tm-convert-blocks-to-items/releases/tag/07-04-22), to automate the creation of `.Block.Gbx` files from the internally stored `.EDClassic.Gbx` files, with some more features added onto it.

## Overview

EDClassic&Item Converter is made to more easily create the more mouldable `.Blocks.Gbx` files (without having the need to look into, or use any `.Prefab.Gbx` nonsense). 
It currently supports `.EDClassic.Gbx` to `.Block.Gbx` for most files blocks, `.EDClassic.Gbx` to `.Block.Gbx` (but only the 'links' in case you want to edit water blocks too), `.EDClassic.Gbx` to `.Item.Gbx` for most blocks. With a planned addition of converting Nadeo Anchored objects to `.Item.Gbx` files.

## Feature(s)

- **Multi-Type Conversion: ** The plugin supports various ways of conversion, including Block-To-Block, Block-To-Item, Block-To-Block_LInks, and with Item-To-Item conversion on the way. 

## ⚠️ Important Notes

1. **Limitations:**
  - Not all blocks are currently supported. Some blocks cannot have their mesh added (some bob waypoints), and some blocks consistently crash the game when opened in the Mesh Modeler.
2. **Stability:**
  - The Plugin, at least to some extent, relies on UI automation, I've included a widget and a setting so that this can be accounted for in future updates, but if the UI changes these values will have to be changed manually...

## Prerequisites

- [Trackmania](http://trackmania.com/) game installed

## How It Works

- **Initialization:**
  - Upon launching, the plugin checks the selected conversion type from the settings and prepares the necessary environment by loading the required library and initializing the mouse controller.
- **Conversion Process:**
  - Based on the chosen conversion type, the plugin navigates through the Trackmania game editor's inventory, identifies eligible blocks or items, and performs the conversion using automated mouse movements and clicks.
- **Safety and Blacklisting:**
  - During the conversion, the plugin respects the predefined blacklists, skipping any blocks or items that are known to cause issues.
- **Saving Converted Assets:**
  - Successfully converted blocks or items are saved to designated folders within the user's "Trackmania[2020]/Blocks" or "Trackmania[2020]/Items" directory.

## Credits

- **Author:** ar
