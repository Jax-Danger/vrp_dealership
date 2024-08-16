local cfg = {}

cfg.useGroup = true --[[ If you want to use a group to access the dealership, 
set this to true and set the group in the next line]]
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
  [3] = {coords = {-41.4787, -1094.1528, 26.4224}, rot = 64.6650},
  [4] = {coords = {-40.8232, -1101.3252, 26.4223}, rot = 253.2162}
}

cfg.display_vehicles = {
  positions = {
    [1] = "super",
    [2] = "sports",
    [3] = "sedan",
    [4] = "compact"
  },
  ["super"] = {
    {display = "Nero", model = "nero", price = 85000},
    {display = "Osiris", model = "osiris", price = 72000},
    {display = "T20", model = "t20", price = 72000},
    {display = "Reaper", model = "reaper", price = 65000},
    {display = "Cheetah", model = "cheetah", price = 50800},
    {display = "Zentorno", model = "zentorno", price = 50000},
    {display = "Adder", model = "adder", price = 45000},
    {display = "Bullet", model = "bullet", price = 42065},
    {display = "Turismo R", model = "turismor", price = 40000},
    {display = "Entity XF", model = "entityxf", price = 35000},
    {display = "Vacca", model = "vacca", price = 32000},
    {display = "Infernus", model = "infernus", price = 30450}
  },
  ["sports"] = {
    {display = "Comet", model = "comet2", price = 30000},
    {display = "Seven-70", model = "seven70", price = 29000},
    {display = "Massacro", model = "massacro", price = 28000},
    {display = "Specter", model = "specter", price = 27000},
    {display = "Jester", model = "jester", price = 26000},
    {display = "Carbonizzare", model = "carbonizzare", price = 25000},
    {display = "Coquette", model = "coquette", price = 22000},
    {display = "Feltzer", model = "feltzer2", price = 20500},
    {display = "Elegy", model = "elegy2", price = 10000},
    {display = "Fusilade", model = "fusilade", price = 15000},
    {display = "Kuruma", model = "kuruma", price = 20000}
  },
  ["sedan"] = {
    {display = "Tailgater", model = "tailgater", price = 20000},
    {display = "Fugitive", model = "fugitive", price = 15000},
    {display = "Asterope", model = "asterope", price = 18000},
    {display = "Intruder", model = "intruder", price = 16000},
    {display = "Premier", model = "premier", price = 15000},
    {display = "Primo", model = "primo", price = 15000},
    {display = "Warrener", model = "warrener", price = 16000},
    {display = "Stanier", model = "stanier", price = 15000},
    {display = "Stratum", model = "stratum", price = 15000},
    {display = "Schafter", model = "schafter2", price = 20000},
    {display = "Schafter V12", model = "schafter3", price = 25000},
    {display = "Schafter LWB", model = "schafter4", price = 30000},
    {display = "Schafter LWB 2", model = "schafter5", price = 35000},
    {display = "Schafter V12", model = "schafter6", price = 40000},
    {display = "Primo Custom", model = "primo2", price = 15000},
    {display = "Regina", model = "regina", price = 15000},
    {display = "Asea", model = "asea", price = 15000},
    {display = "Asterope", model = "asterope", price = 15000},
    {display = "Cognoscenti", model = "cognoscenti", price = 20000}
  },
  ["compact"] = {
    {display = "Blista", model = "blista", price = 10000},
    {display = "Prairie", model = "prairie", price = 15000},
    {display = "Rhapsody", model = "rhapsody", price = 13000},
    {display = "Panto", model = "panto", price = 15100},
    {display = "Issi", model = "issi2", price = 13500},
    {display = "Dilettante", model = "dilettante", price = 15000},
    {display = "Brioso", model = "brioso", price = 11500},
    {display = "Futo", model = "futo", price = 14500},
    {display = "Blista Compact", model = "blista2", price = 15000}
  }
}

cfg.vehicle_spawn = {
  coords = {-30.5033, -1090.1926, 26.4222},
  rot = 335.1983
}

cfg.vehicle_discounts = {
  -- percentage
  ["super"] = 10,
  ["sports"] = 15,
  ["sedan"] = 12,
  ["compact"] = 25
}

return cfg
