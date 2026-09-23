# BeastCare

BeastCare is a Hunter pet-care addon for:

- **World of Warcraft: Classic : Vanilla**
- **World of Warcraft: Anniversary: The Burning Crusade**
- **World of Warcraft: Forever Beta**

It helps Hunters track pet happiness, loyalty, feeding, healing and training information without adding unnecessary UI clutter.

## Features

- Active pet status via `/bc status`:
  - Pet name
  - Pet family
  - Pet level
  - Health
  - Experience and progress percentage
  - Available training points
  - Happiness
  - Accepted food types
  - Loyalty level and title

- Feeding reminders:
  - Raid-warning-style visual alert
  - Optional audio alert
  - Separate messages for Content and Unhappy pets
  - Configurable repeat interval from 5 to 60 seconds

- Smart warning behaviour:
  - No warning while you are in combat
  - No warning while your pet is in combat
  - No warning when your pet is dead
  - No warning when no pet is active
  - Warnings stop when your pet is Happy

- Loyalty level-up notifications:
  - Chat message
  - Gold-coloured on-screen notification
  - Subtle sound effect
  
- Pet level-up notifications:
 - Chat message
 - Gold-coloured on-screen notification
 - Subtle sound effect

- Feed Pet Effect timer:
  - Shows the active Feed Pet Effect buff and remaining duration
  - Works without selecting your pet
  - Draggable window
  - Window position is saved

- Mend Pet timer:
  - Shows the active Mend Pet effect and remaining duration
  - Works with all Mend Pet spell ranks
  - Works without selecting your pet
  - Draggable window
  - Window position is saved
  - Can be enabled or disabled in the Options panel

- Pet inspection:
  - Inspect a selected player's pet with `/bc inspect`
  - Shows pet name and family

- Persistent settings:
  - Warning interval
  - Feeding warnings enabled/disabled
  - Warning sound enabled/disabled
  - Mend Pet timer enabled/disabled
  - Feed Pet Effect window position
  - Mend Pet window position

## Installation

1. Download the BeastCare ZIP file.
2. Extract the `BeastCare` folder into your WoW AddOns directory:

    ```text
    World of Warcraft\Interface\AddOns\
    ```

3. The final structure should look like this:

    ```text
    Interface\AddOns\BeastCare\
    ├── BeastCare.toc
    ├── BeastCare.lua
	├── BeastCare_Forever.lua
    ├── BeastCare_Inspect.lua
    ├── BeastCare.tga
    └── README.md
    ```

4. Start World of Warcraft.
5. At the character-selection screen, click **AddOns** and make sure BeastCare is enabled.

## Commands

| Command | Description |
|---|---|
| `/bc` or `/beastcare` | Show addon version and basic help |
| `/bc status` | Show active pet status |
| `/bc inspect` | Show the name and family of a selected player's pet |
| `/bc settings` | Show current BeastCare settings |
| `/bc options` | Open BeastCare options |
| `/bc help` | Show available commands |
| `/bc interval 20` | Set the feeding-warning interval in seconds |
| `/bc warnings on` | Enable feeding warnings |
| `/bc warnings off` | Disable feeding warnings |
| `/bc sound on` | Enable warning sounds |
| `/bc sound off` | Disable warning sounds |
| `/bc feedwindow reset` | Reset the Feed Pet Effect window position |
| `/bc mendwindow reset` | Reset the Mend Pet window position |

The warning interval can be set from **5** to **60** seconds.

## Supported Game Versions

- **World of Warcraft: Classic:Vanilla**
  - Interface version: `11509`

- **World of Warcraft: Anniversary: The Burning Crusade**
  - Interface version: `20506`

- **World of Warcraft: Forever Beta**
  - Interface version: `16001`
  - Beta compatibility is being tested.
  
 ## Known Issues

WoW Forever Beta limitation!
WoW Forever Beta currently has a known Blizzard client issue with addon SavedVariables.
BeastCare settings and timer-window positions can reset after /reload, logging out or restarting the game. The addon saves the information correctly, but the WoW Forever client may fail to load the saved data back into the addon.
This is a WoW Forever Beta client issue that also affects other addons. BeastCare keeps normal SavedVariables support, so settings and window positions work normally in Classic Vanilla and TBC Anniversary. 

## Author

Created by **ThuraNL (PalletjeNL)**.

## Version History

### 0.1.0

- Initial release
- Pet status command
- Happiness and feeding alerts
- Configurable alert interval and sound
- Loyalty level-up notifications
- Draggable Feed Pet Effect timer window
- Saved settings and window position

### 0.1.1

- Added custom addon icon
- Added in-game Options panel
- Added pet family and food types to `/bc status`
- Added pet experience and progress percentage to `/bc status`
- Added available training points to `/bc status`
- Added `/bc inspect` for a selected player's pet
- Improved `/bc status` and `/bc help` chat formatting
- Added separate `BeastCare_Inspect.lua` module

### 0.1.2

- Added draggable Mend Pet timer window
- Added `/bc mendwindow reset`
- Added Mend Pet window reset button to the Options panel
- Improved internal buff-timer window handling
- Removed temporary training-points debug command

### 0.1.3

- Added an option to enable or disable the Mend Pet timer
- Added the Mend Pet timer status to `/bc settings`
- Mend Pet timer is enabled by default
- Added WoW Forever Beta interface compatibility

## 0.2.0

- Added tested WoW Forever Beta support
- Added WoW Forever support for:
    Happiness
    Loyalty titles
    Food types
    Training points
    Feed Pet Effect timer
    Mend Pet timer
- Added loyalty-title change notifications for WoW Forever
- Added pet level-up notifications for all supported game versions
- Kept Classic Vanilla and TBC Anniversary support
- Documented the known WoW Forever Beta SavedVariables limitation