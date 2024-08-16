local DealerShip = class("DealerShip", vRP.Extension)
DealerShip.tunnel = {}

-- Local functions
local function purchaseVeh(self)
  local user = vRP.users_by_source[source]
  if user then
    local curWallet = user:getWallet()
    local vehPrice = self.remote.getVehPrice(user.source, self)
    local prompt = user:request("Confirm purchase for $" .. vehPrice .. ".", 5)
    if prompt then
      if curWallet >= vehPrice then
        user:tryFullPayment(vehPrice, nil)
        vRP.EXT.Base.remote._notify(user.source, "You have purchased a vehicle for $" .. vehPrice)
        local nvehicle = self.remote.getNearestVehicle(user.source, self)
        local model = nvehicle.model
        if model == nil then
          vRP.EXT.Base.remote._notify(user.source, "No vehicle found. Model is nil.")
          return
        end
        print("Spawning vehicle: " .. model)
        self.remote._spawnVehicle(user.source, self, model)
      else
        vRP.EXT.Base.remote._notify(user.source, "You do not have enough money to purchase this vehicle.")
      end
    else
      vRP.EXT.Base.remote._notify(user.source, "Cancelled purchase vehicle.")
    end
  end
end

local function changeVehicle(self, menu)
  local user = vRP.users_by_source[source]
  local nvehicle = self.remote.getNearestVehicle(user.source, self)
  local x, y, z = nvehicle.x, nvehicle.y, nvehicle.z
  local nveh = nvehicle.model
  local nvehclass = nvehicle.class
  print(x .. ", " .. y .. ", " .. z .. " for vehicle: " .. nveh .. " in class: " .. nvehclass)
  local vehiclesByClass = {}

  for class, vehicles in pairs(self.cfg.display_vehicles) do
    if class ~= "positions" then -- Skip the positions key
      vehiclesByClass[class] = vehicles
    end
  end
  vRP.EXT.GUI:registerMenuBuilder(
    "dealership.cars",
    function(menu)
      menu.title = "Vehicle Options"
      menu.css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}
      menu.options = {} -- Clear existing options

      for class, vehicles in pairs(vehiclesByClass) do
        if class == nvehclass then -- Only add vehicles of matching class
          for _, vehicle in ipairs(vehicles) do
            menu:addOption(
              vehicle.display,
              function(player)
                print("Selected vehicle: " .. vehicle.display)
                self.remote._replaceVehicle(user.source, self, nveh, vehicle.model, {x, y, z})
              end
            )
          end
        end
      end
    end
  )
  user:openMenu("dealership.cars")
end

-- Tunnels
function DealerShip:purchaseMenu(action)
  local user = vRP.users_by_source[source]
  if action == "open" then
    user:openMenu("dealership")
  elseif action == "close" then
    user:closeMenus()
  end
end
DealerShip.tunnel.purchaseMenu = DealerShip.purchaseMenu

function DealerShip:getGroup()
  local user = vRP.users_by_source[source]
  local group = user:getGroup()
  if user then
    if group == "cardealer" then
      print("User is a car dealer." .. group)
      return true
    else
      print("User is not a car dealer." .. group)
      return false
    end
  end
end
DealerShip.tunnel.getGroup = DealerShip.getGroup

-- Constructor
function DealerShip:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp_dealership", "cfg/cfg")

  -- Register menu builders
  vRP.EXT.GUI:registerMenuBuilder(
    "dealership",
    function(menu)
      menu.title = "Vehicle Options"
      menu.css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}

      menu:addOption(
        "Purchase vehicle",
        function(player)
          purchaseVeh(self)
        end
      )
    end
  )

  vRP.EXT.GUI:registerMenuBuilder(
    "dealership",
    function(menu)
      menu.title = "Vehicle Options"
      menu.css = {top = "75px", header_color = "rgba(0,125,255,0.75)"}

      menu:addOption(
        "Change vehicle",
        function(player)
          changeVehicle(self, menu)
        end
      )
    end
  )
end

vRP:registerExtension(DealerShip)
