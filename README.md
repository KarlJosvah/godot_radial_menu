# Radial Menu for Godot 4

A versatile, highly customizable, and component-based radial selection menu (wheel menu) for **Godot 4**. Designed for game inventories, spell selectors, weapon wheels, emote wheels, and cascading sub-menus.

![Godot 4](https://img.shields.io/badge/Godot-4.x-478cbf?logo=godotengine&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Gamepad & Mouse Input**:
  - Full analog joystick navigation with configurable stick axes (`ANY`, `LEFT`, `RIGHT`) and automatic deadzone handling.
  - Smooth mouse selection support with captured cursor coordinate tracking.
- **Linked Sub-Menus**:
  - Seamlessly cascade multiple menus together: hovering over an item on the main wheel can automatically open a secondary specialized wheel.
- **Procedural Canvas Rendering**:
  - Dynamic inner/outer radius sizing relative to viewport dimensions.
  - Customizable background color, slice dividing lines, active selection highlight, and line widths.
- **Smooth Animations**:
  - Built-in Ease-In and Ease-Out scale tween animations when opening or closing.
- **Component Architecture**:
  - Core logic cleanly decoupled across specialized child nodes (`Input`, `Render`, `Interact`, `Config`, `Linked`).
  - Automatically instantiates required helper components when created through the "Create New Node" editor dialog.
- **Editor Tool Support**:
  - Full `@tool` rendering directly inside the Godot 2D workspace with property validation and dynamic inspector updates.

---

## Installation

### Manual Installation
1. Download the latest `radial_menu.zip` from the [Releases](https://github.com/KarlJosvah/godot_radial_menu/releases) tab.
2. Extract the `addons/radial_menu` folder into your Godot project's `res://addons/` directory.
3. In the Godot editor, go to **Project ➔ Project Settings ➔ Plugins** and enable **Radial Menu**.

---

## Quick Start

### 1. Adding to a Scene
You can add the radial menu to your scene in two ways:
- **As a Node**: Add a `RadialMenu` node from the "Create New Node" dialog.
- **As a Packed Scene**: Instance `res://addons/radial_menu/radial_menu.tscn` directly into your UI canvas.

### 2. Creating Options
Each item on the wheel is a `RadialMenuOption` resource (which extends `AtlasTexture`):
1. In the Inspector for `RadialMenu`, expand the **Items** group.
2. Add elements to the **Options** array.
3. For each element, create a `New RadialMenuOption`:
   - Set **Option Name** (e.g. `"Fire Ball"`, `"Heal"`, or `"Cancel"`).
   - Set **Atlas** to your icon texture.
   - Adjust **Region** if using a sprite sheet (or leave empty to use the full texture).

> **Note**: Index `0` is typically reserved for the neutral/center cancel action. Options from index `1` upwards are mapped clockwise around the wheel slices.

### 3. Basic Script Usage

```gdscript
extends CanvasLayer

@onready var radial_menu: RadialMenu = $RadialMenu
@onready var label: Label = $Label

func _ready() -> void:
    radial_menu.on_selection_change.connect(_on_selection_changed)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("open_wheel"):
        radial_menu.open()
    elif Input.is_action_just_released("open_wheel"):
        var selected_index: int = radial_menu.close()
        _handle_selection(selected_index)

func _on_selection_changed(index: int) -> void:
    if index >= 0 and index < radial_menu.options.size() and radial_menu.options[index]:
        label.text = "Hovering: " + radial_menu.options[index].option_name

func _handle_selection(index: int) -> void:
    if index >= 0 and index < radial_menu.options.size() and radial_menu.options[index]:
        print("Confirmed action: ", radial_menu.options[index].option_name)
```

---

## Signals

| Signal | Arguments | Description |
|---|---|---|
| `on_wheel_opened` | None | Emitted when the radial menu finishes opening. |
| `on_selection_change` | `selected_index: int` | Emitted whenever the highlighted option index changes. |
| `on_wheel_closed` | `selected_index: int` | Emitted when the radial menu is closed, returning the chosen index (`-1` if cancelled/invalid). |

---

## Linked Menus (Cascading Sub-wheels)

To create secondary menus that open when a primary menu item is selected:

1. Create your child `RadialMenu` nodes in the scene.
2. On the parent `RadialMenu`:
   - Enable **Linked Wheel** in the Inspector.
   - The **Linked Wheels** array will automatically match the size of your **Options** array.
   - Assign the child menu nodes to the corresponding indices in the **Linked Wheels** array.
3. The parent menu's internal `Linked` component will automatically handle opening and closing child wheels as the user navigates between slices.

---

## Included Demos

- **`01/main_01.tscn`**: A basic demo showcasing a single radial menu with mouse/gamepad input and selection labels.
- **`02/main_02.tscn`**: An advanced demo showcasing dual radial menus and dynamic linked cascading sub-wheels.

---

## Project Structure

```text
res://
├── addons/radial_menu/             # The standalone, distributable plugin
│   ├── plugin.cfg                  # Plugin metadata
│   ├── radial_menu_plugin.gd       # EditorPlugin registration
│   ├── radial_menu.tscn            # Clean base template scene
│   ├── radial_menu.gd              # Main controller
│   ├── radial_menu_option.gd       # RadialMenuOption resource class
│   ├── radial_menu_config.gd       # Radius & layout calculation
│   ├── radial_menu_input.gd        # Mouse & stick input parsing
│   ├── radial_menu_interact.gd     # Open/close state & tween animation
│   ├── radial_menu_linked.gd       # Cascading sub-wheel logic
│   └── radial_menu_render.gd       # Canvas procedural drawing
├── 01/                             # Single menu demo scene
├── 02/                             # Dual & linked menu demo scene
├── assets/                         # Sample icons and textures
└── release-notes/                  # Markdown release notes for each version
```

---

## CI/CD Releases

Automated releases are managed via GitHub Actions ([.github/workflows/release.yml](.github/workflows/release.yml)):
1. Bump the `version` field in `addons/radial_menu/plugin.cfg`.
2. Add a matching release note file in `release-notes/v<version>.md` (e.g. `release-notes/v1.0.1.md`).
3. Push changes to `main`. The workflow automatically packages `radial_menu.zip`, tags the commit, and publishes a GitHub Release with the release notes attached.
