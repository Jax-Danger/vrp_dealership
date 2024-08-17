--Main Information
fx_version "cerulean"
game "gta5"
lua54 "yes"

dependencies {
  "vrp"
}

server_script {
  "@vrp/lib/utils.lua",
  "server_vrp.lua"
}

client_script {
  "@vrp/lib/utils.lua",
  "cl_vrp.lua"
}

files {
  "client.lua",
  "cfg/cfg.lua"
}

shared_scripts {
  "@ox_lib/init.lua"
}

escrow_ignore "cfg/cfg.lua"
