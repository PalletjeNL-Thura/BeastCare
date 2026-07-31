# BeastCare

Current version: 0.1.1


BeastCare is a Hunter pet-care addon for **World of Warcraft: Burning Crusade Anniversary**.

It helps Hunters keep track of pet happiness, loyalty and feeding, with clear alerts when a pet needs attention.

## Features

- Pet status command with:
  - Pet name
  - Pet level
  - Health
  - Happiness
  - Loyalty level and title

- Feeding reminders:
  - Raid-warning-style visual alert
  - Audio alert
  - Separate messages for Content and Unhappy pets
  - Configurable repeat interval

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

- Feed Pet Effect timer:
  - Shows the active Feed Pet Effect buff and its remaining duration
  - Works without selecting your pet
  - Draggable window
  - Window position is saved

- Persistent settings:
  - Warning interval
  - Warning enabled/disabled
  - Sound enabled/disabled
  - Feed Pet Effect window position

## Installation

1. Download or copy the `BeastCare` folder.
2. Place it in your WoW AddOns directory:

    World of Warcraft\Interface\AddOns\

3. The final structure should look like this:

    Interface\AddOns\BeastCare\
    ├── BeastCare.toc
    ├── BeastCare.lua
    ├── BeastCare.tga
    └── README.md

4. Start World of Warcraft.
5. At the character-selection screen, click **AddOns** and make sure BeastCare is enabled.

## Commands

| Command | Description |
|---|---|
| `/bc` or `/beastcare` | Show addon version and basic help |
| `/bc status` | Show active pet status |
| `/bc settings` | Show current BeastCare settings |
| `/bc help` | Show available commands |
| `/bc interval 20` | Set the feeding-warning interval in seconds |
| `/bc warnings on` | Enable feeding warnings |
| `/bc warnings off` | Disable feeding warnings |
| `/bc sound on` | Enable warning sounds |
| `/bc sound off` | Disable warning sounds |
| `/bc feedwindow reset` | Reset the Feed Pet Effect window position |

The warning interval can be set from **5** to **60** seconds.

## Supported Game Version

- World of Warcraft: Burning Crusade Anniversary
- Interface version: `20506`

## Author

Created by **ThuraNL**.

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

- Added addon icon
- Added in-game Options panel
- Added pet family and food types to `/bc status`
- Added pet experience progress to `/bc status`
- Added available training points to `/bc status`
- Added `/bc inspect` for a selected player's pet
- Improved chat output formatting
