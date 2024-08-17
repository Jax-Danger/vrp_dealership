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

  Citizen.CreateThread(
    function()
      local blip = AddBlipForCoord(x, y, z)
      if not DoesBlipExist(blip) then
        print("Failed to create blip")
        return
      end

      SetBlipSprite(blip, v.id)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, v.scale)
      SetBlipColour(blip, v.color)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(self.cfg.dealership.name)
      EndTextCommandSetBlipName(blip)
      print("Blip created successfully")
    end
  )
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
      print("loading position: " .. x .. ", " .. y .. ", " .. z .. ", " .. h .. " for model: " .. model)
      local vehicle = GetHashKey(model)
      RequestModel(vehicle)
      while not HasModelLoaded(vehicle) do
        Citizen.Wait(10)
      end
      local veh = CreateVehicle(vehicle, x, y, z, h, true, false)
      SetVehicleOnGroundProperly(veh)
      SetEntityAsMissionEntity(veh, true, true)
      SetVehicleDoorsLocked(veh, 2) -- Lock the vehicle
      FreezeEntityPosition(veh, true) -- Freeze the vehicle
      SetEntityInvincible(veh, true) -- Make the vehicle indestructible
      SetModelAsNoLongerNeeded(vehicle)
      if useText then
        --print("self.cfg.display_vehicles:", json.encode(self.cfg.display_vehicles)) -- Debug print
        local class = getVehicleClassFromModel(self, model)
        --print("model:", model) -- Debug print
        --print("class:", table.unpack(class)) -- Debug print
        local vehicleClass = self.cfg.display_vehicles[class]
        --print("vehicleClass:", vehicleClass) -- Debug print
        if vehicleClass then
          Citizen.CreateThread(
            function()
              while DoesEntityExist(veh) do
                Citizen.Wait(10)
                local vehCoords = GetEntityCoords(veh)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(vehCoords - playerCoords)
                if distance < 3.0 then
                  for _, v in ipairs(vehicleClass) do
                    if model == v.model then
                      local text =
                        string.format(
                        "Class: %s\nModel: %s\nPrice: $%s",
                        class,
                        v.display or v.model,
                        v.price or "Unknown"
                      )
                      DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.25, text)
                    end
                  end
                end
              end
            end
          )
        else
          print("vehicleClass is nil")
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
      --print("class:", class)
      --print("vehicleClass:", vehicleClass)
      if vehicleClass and #vehicleClass > 0 then
        local x, y, z = table.unpack(vehPos.coords)
        local vehicle = GetHashKey(vehicleClass[1].model)
        RequestModel(vehicle)
        while not HasModelLoaded(vehicle) do
          Citizen.Wait(10)
        end
        local veh = CreateVehicle(vehicle, x, y, z - 1.0, vehPos.rot, true, false)
        SetVehicleOnGroundProperly(veh) -- Ensure the vehicle is on the ground properly
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleNumberPlateText(veh, "DEALER")
        SetVehicleDoorsLocked(veh, 2) -- Lock the vehicle
        FreezeEntityPosition(veh, true) -- Freeze the vehicle
        SetEntityInvincible(veh, true) -- Make the vehicle indestructible
        SetModelAsNoLongerNeeded(vehicle)

        -- Ensure text is displayed above the vehicle
        Citizen.CreateThread(
          function()
            while DoesEntityExist(veh) do
              Citizen.Wait(10)
              local vehCoords = GetEntityCoords(veh)
              local playerCoords = GetEntityCoords(PlayerPedId())
              local distance = #(vehCoords - playerCoords)
              if distance < 3.0 then
                for _, v in ipairs(vehicleClass) do
                  if vehicleClass[1].model == v.model then
                    local text =
                      string.format(
                      "Class: %s\nModel: %s\nPrice: $%s",
                      class,
                      v.display or v.model,
                      v.price or "Unknown"
                    )
                    DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.25, text)
                  end
                end
              end
            end
          end
        )
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

function DealerShip:getNearestVehicle()
  local playerCoords = GetEntityCoords(PlayerPedId())
  local nearestVehicle = nil
  local nearestDistance = math.huge

  for posIndex, class in pairs(self.cfg.display_vehicles.positions) do
    local position = self.cfg.positions[posIndex]
    local vehicleClass = self.cfg.display_vehicles[class]

    if vehicleClass and #vehicleClass > 0 then
      for _, vehicle in ipairs(vehicleClass) do
        local x, y, z = table.unpack(position.coords)
        local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z)

        if distance <= 2.5 and distance < nearestDistance then
          nearestDistance = distance
          local nvehicle = vRP.EXT.Garage:getNearestVehicle(2.0)
          if nvehicle then
            local modelHash = GetEntityModel(nvehicle)
            local modelName = GetDisplayNameFromVehicleModel(modelHash)
            nearestVehicle = {
              x = x,
              y = y,
              z = z,
              model = modelName,
              class = class
            }
          end
        end
      end
    end
  end

  if nearestVehicle then
    print("Nearest vehicle: " .. nearestVehicle.model)
    return nearestVehicle
  else
    return print("No vehicle found within the specified range.")
  end
end
DealerShip.tunnel.getNearestVehicle = DealerShip.getNearestVehicle

function DealerShip:spawnVehicle(self, model)
  if not model then
    return print("No model provided " .. model)
  end

  local vehicleHash = GetHashKey(model)
  local x, y, z = table.unpack(self.cfg.vehicle_spawn.coords)
  local rot = self.cfg.vehicle_spawn.rot
  -- Ensure the coordinates are correct
  if not (x and y and z and rot) then
    return print("Invalid vehicle spawn coordinates.")
  end
  -- Spawn the vehicle
  --spawnVehicle(self, model, {x, y, z, rot}, false)
  --teleport player to x,y,z facing rot
  SetEntityCoords(PlayerPedId(), x, y, z - 1.0)
  SetEntityHeading(PlayerPedId(), rot)
  Citizen.Wait(1000)
  vRP.EXT.Garage:spawnVehicle(model)
end
DealerShip.tunnel.spawnVehicle = DealerShip.spawnVehicle

function DealerShip:replaceVehicle(self, vehtoreplace, replacedveh, position)
  local x, y, z = table.unpack(position)
  print(x .. ", " .. y .. ", " .. z)
  print("Replacing vehicle: " .. replacedveh .. " with: " .. vehtoreplace)

  -- Delete the vehicle to replace
  local vehicleToReplace = GetClosestVehicle(x, y, z, 3.0, 0, 70)
  if DoesEntityExist(vehicleToReplace) then
    SetEntityAsMissionEntity(vehicleToReplace, true, true)
    DeleteEntity(vehicleToReplace)
    print("Deleted vehicle at position: " .. x .. ", " .. y .. ", " .. z)
    Citizen.Wait(500) -- Wait a bit before checking again
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
    local spawnX, spawnY, spawnZ = closestCoords[1] + 0.1, closestCoords[2] + 0.1, closestCoords[3]

    spawnVehicle(self, replacedveh, {spawnX, spawnY, spawnZ, closestRot}, true)
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
        Citizen.Wait(1000) -- Update every 1000 ms
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
        Citizen.Wait(1500) -- Check every 1500 ms
      end
    end
  )
end

vRP:registerExtension(DealerShip)
