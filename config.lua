Config = {}

Config.DuiWidth = 384
Config.DuiHeight = 512

Config.HeightMin = 4
Config.HeightMax = 200
Config.MaxDistance = 800

Config.FadeStartDistance = 25

--[[
  Exports (client-side)

  local id = exports['bfx-waypoints']:AddWaypoint(pos, {
    label      = "DELIVERY",       -- default "WAYPOINT"
    color      = "#E74C3C",        -- default "#FFFFFF"
    autoRemove = true,             -- default true
    removeDist = 5.0,              -- default 5.0
  })

  exports['bfx-waypoints']:RemoveWaypoint(id)  --> bool
  exports['bfx-waypoints']:UpdateWaypoint(id, { pos = vec3, label = "X", color = "#FF0000" })  --> bool
  exports['bfx-waypoints']:GetWaypointForCoord(pos, radius?)  --> id | nil   (radius defaults to 1.0)
  exports['bfx-waypoints']:ClearWaypoints()
]]
