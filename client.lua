local DealerShip = class("DealerShip", vRP.Extension)
DealerShip.tunnel = {}

function DrawText3D(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local px, py, pz = table.unpack(GetGameplayCamCoords())
  local scale = 0.75

  if onScreen then
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
  end
end
function blips(self)
  local x, y, z = table.unpack(self.cfg.dealership.coords)
  print("blips " .. x, y, z)
  local v = self.cfg.dealership.blip
  local blip = AddBlipForCoord(x, y, z)
  SetBlipSprite(blip, v.id)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, v.scale)
  SetBlipColour(blip, v.color)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(self.cfg.dealership.name)
  EndTextCommandSetBlipName(blip)
end
function getVehicleClassFromModel(self, model)
  for class, vehicles in pairs(self.cfg.display_vehicles) do
    if type(vehicles) == "table" then
      for _, vehicleData in ipairs(vehicles) do
        if vehicleData.model == model then
          return class
        end
      end
    end
  end
  return nil
end

function spawnVehicle(self, model, position, useText)
  if position then
    local x, y, z, h = position[1], position[2], position[3], position[4]
    if (x and y and z and h) ~= nil then
      print("loading position: " .. x .. ", " .. y .. ", " .. z .. ", " .. h)
      local vehicle = GetHashKey(model)
      RequestModel(vehicle)
      while not HasModelLoaded(vehicle) do
        Citizen.Wait(0)
      end
      local veh = CreateVehicle(vehicle, x, y, z, h, true, false)
      SetVehicleOnGroundProperly(veh)
      SetEntityAsMissionEntity(veh, true, true)
      SetVehicleDoorsLocked(veh, 2) -- Lock the vehicle
      FreezeEntityPosition(veh, true) -- Freeze the vehicle
      SetEntityInvincible(veh, true) -- Make the vehicle indestructible
      SetModelAsNoLongerNeeded(vehicle)
      if useText then
        print("self.cfg.display_vehicles:", json.encode(self.cfg.display_vehicles)) -- Debug print
        local class = getVehicleClassFromModel(self, model)
        print("model:", model) -- Debug print
        print("class:", class) -- Debug print
        local vehicleClass = self.cfg.display_vehicles[class]
        print("vehicleClass:", vehicleClass) -- Debug print
        if vehicleClass then
          Citizen.CreateThread(
            function()
              while DoesEntityExist(veh) do
                Citizen.Wait(0)
                local vehCoords = GetEntityCoords(veh)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(vehCoords - playerCoords)
                if distance < 3.0 then
                  local text =
                    string.format(
                    "Class: %s\nModel: %s\nPrice: $%s",
                    class,
                    vehicleClass[1].display or vehicleClass[1].model,
                    vehicleClass[1].price or "Unknown"
                  )
                  DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.0, text)
                end
              end
            end
          )
        else
          print("vehicleClass is nil for class:", class)
        end
      end
    else
      print("Invalid position data.")
    end
  else
    print("Position is nil. Spawning vehicle(s) at default location")
    for posIndex, class in pairs(self.cfg.display_vehicles.positions) do
      local vehPos = self.cfg.positions[posIndex]
      local vehicleClass = self.cfg.display_vehicles[class]
      print("class:", class)
      print("vehicleClass:", vehicleClass)
      if vehicleClass and #vehicleClass > 0 then
        local x, y, z = table.unpack(vehPos.coords)
        local vehicle = GetHashKey(vehicleClass[1].model)
        RequestModel(vehicle)
        while not HasModelLoaded(vehicle) do
          Citizen.Wait(0)
        end
        local veh = CreateVehicle(vehicle, x, y, z - 0.85, vehPos.rot, true, false)
        SetVehicleOnGroundProperly(veh) -- Ensure the vehicle is on the ground properly
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleNumberPlateText(veh, "DEALER")
        SetVehicleDoorsLocked(veh, 2) -- Lock the vehicle
        FreezeEntityPosition(veh, true) -- Freeze the vehicle
        SetEntityInvincible(veh, true) -- Make the vehicle indestructible
        SetModelAsNoLongerNeeded(vehicle)

        if useText then
          Citizen.CreateThread(
            function()
              while DoesEntityExist(veh) do
                Citizen.Wait(0)
                local vehCoords = GetEntityCoords(veh)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(vehCoords - playerCoords)
                if distance < 3.0 then
                  local text =
                    string.format(
                    "Class: %s\nModel: %s\nPrice: $%s",
                    class,
                    vehicleClass[1].display or vehicleClass[1].model,
                    vehicleClass[1].price or "Unknown"
                  )
                  DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.0, text)
                end
              end
            end
          )
        end
      else
        print("vehicleClass is nil or empty for class:", class)
      end
    end
  end
end
-- Tunnels
function DealerShip:getVehPrice(self)
  local playerCoords = GetEntityCoords(PlayerPedId())
  local nearestPrice = nil
  local nearestDistance = math.huge

  for posIndex, class in pairs(self.cfg.display_vehicles.positions) do
    local position = self.cfg.positions[posIndex]
    local vehicleClass = self.cfg.display_vehicles[class]

    if vehicleClass and #vehicleClass > 0 then
      local x, y, z = table.unpack(position.coords)
      local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z)

      if distance <= 2.5 and distance < nearestDistance then
        local nearestVehicle = GetClosestVehicle(x, y, z, 3.0, 0, 70)
        if DoesEntityExist(nearestVehicle) then
          local nearestModel = GetEntityModel(nearestVehicle)
          for _, veh in ipairs(vehicleClass) do
            if GetHashKey(veh.model) == nearestModel then
              nearestDistance = distance
              nearestPrice = veh.price
              break
            end
          end
        end
      end
    end
  end
  return nearestPrice
end
DealerShip.tunnel.getVehPrice = DealerShip.getVehPrice

function DealerShip:getNearestVehicle(self)
  local playerCoords = GetEntityCoords(PlayerPedId())
  local nearestVehicle = nil
  local nearestDistance = math.huge

  for posIndex, class in pairs(self.cfg.display_vehicles.positions) do
    local position = self.cfg.positions[posIndex]
    local vehicleClass = self.cfg.display_vehicles[class]

    if vehicleClass and #vehicleClass > 0 then
      local x, y, z = table.unpack(position.coords)
      local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z)

      if distance <= 2.5 and distance < nearestDistance then
        nearestDistance = distance
        nearestVehicle = {
          x = x,
          y = y,
          z = z,
          model = vehicleClass[1].model,
          class = class
        }
      end
    end
  end

  if nearestVehicle then
    print(nearestVehicle.x, nearestVehicle.y, nearestVehicle.z, nearestVehicle.model, nearestVehicle.class)
  else
    print("No nearest vehicle found")
  end

  return nearestVehicle
end
DealerShip.tunnel.getNearestVehicle = DealerShip.getNearestVehicle

function DealerShip:spawnVehicle(self, model)
  if not model then
    return print("No model provided " .. model)
  end

  print("Model provided: " .. model)

  local vehicleHash = GetHashKey(model)
  print("Vehicle hash: " .. vehicleHash)

  local x, y, z = table.unpack(self.cfg.vehicle_spawn.coords)
  local rot = self.cfg.vehicle_spawn.rot

  print("Vehicle spawn coordinates: ", x, y, z)
  print("Vehicle spawn rotation: ", rot)

  -- Ensure the coordinates are correct
  if not (x and y and z and rot) then
    return print("Invalid vehicle spawn coordinates.")
  end

  -- Print statement to verify coordinates right before spawning the vehicle
  print("Attempting to spawn: " .. model .. " at " .. x .. ", " .. y .. ", " .. z .. " with rotation: " .. rot)

  -- Spawn the vehicle
  spawnVehicle(self, model, {x, y, z, rot}, false)

  -- Wait for the vehicle to be created
  Citizen.Wait(1000)

  -- Get the player's ped and the vehicle entity
  local ped = PlayerPedId()
  local vehicle = GetClosestVehicle(x, y, z, 5.0, vehicleHash, 70)

  if vehicle then
    print("Vehicle spawned: " .. vehicle)
  else
    print("Failed to spawn vehicle.")
  end
end
DealerShip.tunnel.spawnVehicle = DealerShip.spawnVehicle

function DealerShip:replaceVehicle(vehtoreplace, replacedveh, position)
  local x, y, z = table.unpack(position)
  print(x .. ", " .. y .. ", " .. z)
  print("Replacing vehicle: " .. replacedveh .. " with: " .. vehtoreplace)

  -- Delete the vehicle to replace
  local vehicleToReplace = GetClosestVehicle(x, y, z, 3.0, 0, 70)
  if DoesEntityExist(vehicleToReplace) then
    SetEntityAsMissionEntity(vehicleToReplace, true, true)
    DeleteEntity(vehicleToReplace)
    print("Deleted vehicle at position: " .. x .. ", " .. y .. ", " .. z)
    Citizen.Wait(100) -- Wait a bit before checking again
  else
    print("No vehicle found to delete at position: " .. x .. ", " .. y .. ", " .. z)
  end

  -- Find the closest position and rotation from the config
  local closestCoords, closestRot
  for _, posData in pairs(self.cfg.positions) do
    local dist = Vdist(x, y, z, posData.coords[1], posData.coords[2], posData.coords[3])
    if not closestCoords or dist < Vdist(x, y, z, closestCoords[1], closestCoords[2], closestCoords[3]) then
      closestCoords, closestRot = posData.coords, posData.rot
    end
  end

  if closestCoords and closestRot then
    -- Adjust position slightly to avoid overlapping
    local spawnX, spawnY, spawnZ = closestCoords[1] + 0.1, closestCoords[2] + 0.1, closestCoords[3]

    spawnVehicle(self, replacedveh, {spawnX, spawnY, spawnZ, closestRot}, true)

    for _, category in pairs(self.cfg.display_vehicles.positions) do
      for _, veh in ipairs(self.cfg.display_vehicles[category]) do
        if veh.model == replacedveh then
          print(string.format("Class: %s\nModel: %s\nPrice: $%d", category, replacedveh, veh.price))
          return
        end
      end
    end
    print("Vehicle data not found for model: " .. replacedveh)
  else
    print("No positions found in config")
  end
end
DealerShip.tunnel.replaceVehicle = DealerShip.replaceVehicle

-- Constructor
function DealerShip:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_dealership", "cfg/cfg")
  blips(self)
  spawnVehicle(self, nil, nil, true)

  -- Local variables
  local playerCoords = nil
  local isMenuOpen = false

  -- Thread to continuously update player's coordinates
  Citizen.CreateThread(
    function()
      while true do
        local playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        Citizen.Wait(500) -- Update every 500 ms
      end
    end
  )

  -- Thread to check distance and open/close purchase menu
  Citizen.CreateThread(
    function()
      while true do
        if playerCoords then
          local isAnyVehicleNearby = false
          for posIndex, class in pairs(self.cfg.display_vehicles.positions) do
            local position = self.cfg.positions[posIndex]
            local vehicleClass = self.cfg.display_vehicles[class]

            if vehicleClass and #vehicleClass > 0 then
              local x, y, z = table.unpack(position.coords)
              local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z)

              if distance <= 2.5 then
                isAnyVehicleNearby = true
                break
              end
            end
          end

          if isAnyVehicleNearby and not isMenuOpen then
            self.remote._purchaseMenu("open")
            isMenuOpen = true
          elseif not isAnyVehicleNearby and isMenuOpen then
            self.remote._purchaseMenu("close")
            isMenuOpen = false
          end
        end
        Citizen.Wait(500) -- Check every 500 ms
      end
    end
  )
end

vRP:registerExtension(DealerShip)
