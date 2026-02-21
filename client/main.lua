local DUI_URL = ("nui://%s/dui/waypoint.html"):format(GetCurrentResourceName())
local DUI_ASPECT = Config.DuiWidth / Config.DuiHeight

local waypoints = {}
local idCounter = 0
local rendering = false

local function FormatDistance(meters)
  if meters >= 1000.0 then
    return ("%.1fKM"):format(meters / 1000.0)
  end
  return ("%dM"):format(math.floor(meters))
end

-- each waypoint gets its own DUI browser + runtime texture
local function CreateWaypointDui(wp)
  local dui = CreateDui(DUI_URL, Config.DuiWidth, Config.DuiHeight)
  wp.dui = dui
  Wait(500)
  local handle = GetDuiHandle(dui)
  local txd = CreateRuntimeTxd(wp.txdName)
  CreateRuntimeTextureFromDuiHandle(txd, wp.texName, handle)
  SendDuiMessage(dui, json.encode({ beamColor = wp.color, sublabel = wp.label }))
  wp.ready = true
end

local function DestroyWaypointDui(wp)
  wp.ready = false
  if wp.dui then
    DestroyDui(wp.dui)
    wp.dui = nil
  end
end

-- only push to DUI when something changed
local function SendDuiUpdate(wp, distText)
  if not wp.dui then return end
  local msg = {}
  local changed = false

  if distText ~= wp.lastDist then
    msg.distance = distText
    msg.sublabel = wp.label
    wp.lastDist = distText
    changed = true
  end

  if wp.color ~= wp.lastColor then
    msg.beamColor = wp.color
    wp.lastColor = wp.color
    changed = true
  end

  if changed then
    SendDuiMessage(wp.dui, json.encode(msg))
  end
end

-- lazy render loop, only active when waypoints exist
local function StartRenderLoop()
  if rendering then return end
  rendering = true

  CreateThread(function()
    while rendering do
      Wait(0)

      local playerPos = GetEntityCoords(PlayerPedId())
      local hasAny = false

      for id, wp in pairs(waypoints) do
        if not wp.ready then
          hasAny = true
          goto nextWp
        end

        hasAny = true
        local dist = #(vector2(playerPos.x, playerPos.y) - vector2(wp.pos.x, wp.pos.y))

        SendDuiUpdate(wp, FormatDistance(dist))

        local height = Config.HeightMin + (Config.HeightMax - Config.HeightMin) * (dist / Config.MaxDistance)
        local width = height * DUI_ASPECT

        local alpha = 255
        if dist < Config.FadeStartDistance then
          alpha = math.floor((dist / Config.FadeStartDistance) * 255)
        end

        -- auto-remove fade
        if wp.autoRemove and dist < wp.removeDist and not wp.removing then
          wp.removing = true
          wp.fadeAlpha = alpha
        end

        if wp.removing then
          wp.fadeAlpha = wp.fadeAlpha - 5
          alpha = wp.fadeAlpha
          if alpha <= 0 then
            DestroyWaypointDui(wp)
            waypoints[id] = nil
            goto nextWp
          end
        end

        if alpha < 1 then goto nextWp end

        DrawMarker(
          9,
          wp.pos.x, wp.pos.y, wp.pos.z + (height / 2.0),
          0.0, 0.0, 0.0,
          90.0, 0.0, 0.0,
          width, height, 1.0,
          255, 255, 255, alpha,
          false, true, 2, false,
          wp.txdName, wp.texName, false
        )

        ::nextWp::
      end

      -- kill loop when nothing left
      if not hasAny then
        rendering = false
      end
    end
  end)
end

-- api

local function AddWaypoint(pos, opts)
  opts = opts or {}
  idCounter = idCounter + 1
  local id = idCounter

  local autoRemove = opts.autoRemove
  if autoRemove == nil then autoRemove = true end

  waypoints[id] = {
    id = id,
    pos = pos,
    label = opts.label or "WAYPOINT",
    color = opts.color or "#FFFFFF",
    autoRemove = autoRemove,
    removeDist = opts.removeDist or 5.0,
    lastDist = "",
    lastColor = "",
    removing = false,
    fadeAlpha = 255,
    dui = nil,
    ready = false,
    txdName = "bfxwp_txd_" .. id,
    texName = "bfxwp_tex_" .. id,
  }

  CreateThread(function()
    CreateWaypointDui(waypoints[id])
  end)

  StartRenderLoop()
  return id
end

local function RemoveWaypoint(id)
  local wp = waypoints[id]
  if not wp then return false end
  DestroyWaypointDui(wp)
  waypoints[id] = nil
  return true
end

local function UpdateWaypoint(id, data)
  local wp = waypoints[id]
  if not wp then return false end
  if data.pos then wp.pos = data.pos end
  if data.label then wp.label = data.label end
  if data.color then wp.color = data.color end
  return true
end

local function GetWaypointForCoord(pos, radius)
  radius = radius or 1.0
  for id, wp in pairs(waypoints) do
    if #(wp.pos - pos) <= radius then
      return id
    end
  end
  return nil
end

local function ClearWaypoints()
  for id, wp in pairs(waypoints) do
    DestroyWaypointDui(wp)
    waypoints[id] = nil
  end
end

-- exports

exports("AddWaypoint", AddWaypoint)
exports("RemoveWaypoint", RemoveWaypoint)
exports("UpdateWaypoint", UpdateWaypoint)
exports("GetWaypointForCoord", GetWaypointForCoord)
exports("ClearWaypoints", ClearWaypoints)

-- cleanup
AddEventHandler("onResourceStop", function(res)
  if res ~= GetCurrentResourceName() then return end
  ClearWaypoints()
end)


RegisterCommand("test_checkpoint", function()
  AddWaypoint(GetEntityCoords(PlayerPedId()) + vec3(10, 10, 0))
end)