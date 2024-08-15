local cfg = {}

cfg.dealership = {
  name = "DealerShip",
  coords = {-32, -1109, 26},
  blip = {
    id = 225,
    color = 2,
    scale = 1.0
  }
}

cfg.positions = {
  [1] = {coords = {-51.23, -1093.92, 26.42}, rot = 157.82},
  [2] = {coords = {-49.3493, -1100.6406, 26.422}, rot = 319.4419},
  [3] = {coords = {-41.4787, -1094.1528, 26.4224}, rot = 64.6650}
}

cfg.display_vehicles = {
  positions = {
    [1] = "super",
    [2] = "sports",
    [3] = "sedan"
  },
  ["super"] = {
    {display = "Zentorno", model = "zentorno", price = 50000},
    {display = "Adder", model = "adder", price = 45000},
    {display = "Turismo R", model = "turismor", price = 40000}
  },
  ["sports"] = {
    {display = "Comet", model = "comet2", price = 30000},
    {display = "Carbonizzare", model = "carbonizzare", price = 25000}
  },
  ["sedan"] = {
    {display = "Tailgater", model = "tailgater", price = 20000},
    {display = "Fugitive", model = "fugitive", price = 15000}
  }
}

cfg.vehicle_spawn = {
  coords = {-30.5033, -1090.1926, 26.4222},
  rot = 335.1983
}

return cfg
