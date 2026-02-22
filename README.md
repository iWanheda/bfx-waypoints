# 🚀 bfx-waypoints

✨ **3D waypoint beams with real-time distance tracking for FiveM**
Each waypoint renders as a vertical beam with a live-updating distance label and customizable color, built using **DUI (Direct User Interface) textures** for crisp, performant visuals.

![FiveM](https://img.shields.io/badge/FiveM-Client--Side-blue)
![Lua](https://img.shields.io/badge/Lua-5.4-purple)
![License](https://img.shields.io/badge/license-MIT-green)

[![Watch the video](https://img.youtube.com/vi/yhHGI7lbFCU/0.jpg)]([https://youtu.be/yhHGI7lbFCU](https://youtu.be/yhHGI7lbFCU))
---

## 🌟 Features

* 🟦 **3D DUI Beams** — Every waypoint is its own DUI-rendered beam drawn in-world via runtime textures
* 📏 **Live Distance Tracking** — Updates every frame, auto-formats to meters (`123M`) or kilometers (`1.2KM`)
* 🎨 **Custom Colors & Labels** — Set any hex color and custom label per waypoint
* 🧹 **Auto-Remove** — Waypoints fade out and self-destruct when the player reaches them (configurable)
* 🌫️ **Proximity Fade** — Beams smoothly fade to transparent as you approach
* ⚡ **Lazy Rendering** — Render loop only runs while waypoints exist (zero overhead otherwise)
* 🧩 **Clean API** — Five simple exports to add, remove, update, find, and clear waypoints

---

## 📦 Installation

1. Drop the `bfx-waypoints` folder into your server’s `resources` directory
2. Add the following line to your `server.cfg`:

```cfg
ensure bfx-waypoints
```

---

## ⚙️ Configuration

Edit `config.lua` to tweak behavior and visuals:

| Option              | Default | Description                                 |
| ------------------- | ------- | ------------------------------------------- |
| `DuiWidth`          | `384`   | DUI texture width in pixels                 |
| `DuiHeight`         | `512`   | DUI texture height in pixels                |
| `HeightMin`         | `4`     | Minimum beam height (close range)           |
| `HeightMax`         | `200`   | Maximum beam height (far range)             |
| `MaxDistance`       | `800`   | Distance at which beam reaches max height   |
| `FadeStartDistance` | `25`    | Distance below which beams start fading out |

---

## 🔌 Exports (Client-Side)

### ➕ AddWaypoint

Creates a new waypoint and returns its ID.

```lua
local id = exports['bfx-waypoints']:AddWaypoint(pos, {
  label      = "DELIVERY", -- default "WAYPOINT"
  color      = "#E74C3C",  -- default "#FFFFFF"
  autoRemove = true,       -- default true
  removeDist = 5.0,        -- default 5.0
})
```

| Parameter    | Type      | Default      | Description                         |
| ------------ | --------- | ------------ | ----------------------------------- |
| `pos`        | `vector3` | **required** | World position of the waypoint      |
| `label`      | `string`  | `"WAYPOINT"` | Text displayed below the distance   |
| `color`      | `string`  | `"#FFFFFF"`  | Hex color for the beam and divider  |
| `autoRemove` | `boolean` | `true`       | Automatically remove on arrival     |
| `removeDist` | `number`  | `5.0`        | Distance threshold for auto-removal |

---

### ❌ RemoveWaypoint

Removes a waypoint by ID. Returns `true` if found.

```lua
local success = exports['bfx-waypoints']:RemoveWaypoint(id)
```

---

### ♻️ UpdateWaypoint

Updates properties of an existing waypoint. Returns `true` if found.

```lua
exports['bfx-waypoints']:UpdateWaypoint(id, {
  pos   = vec3(100.0, 200.0, 30.0),
  label = "NEW LABEL",
  color = "#00FF00",
})
```

---

### 📍 GetWaypointForCoord

Finds a waypoint near a position. Returns the waypoint ID or `nil`.

```lua
local id = exports['bfx-waypoints']:GetWaypointForCoord(pos, radius)
-- radius defaults to 1.0
```

---

### 🧹 ClearWaypoints

Removes all active waypoints.

```lua
exports['bfx-waypoints']:ClearWaypoints()
```

---

## 🛠️ Usage Example

```lua
-- Create a delivery waypoint
local wpId = exports['bfx-waypoints']:AddWaypoint(vec3(215.0, -810.0, 30.0), {
  label = "DELIVERY",
  color = "#2ECC71",
  removeDist = 3.0,
})

-- Update it later
exports['bfx-waypoints']:UpdateWaypoint(wpId, {
  label = "URGENT",
  color = "#E74C3C",
})

-- Or remove it manually
exports['bfx-waypoints']:RemoveWaypoint(wpId)
```

---

## 🧩 Dependencies

✅ None — this is a **standalone, client-side** resource.
