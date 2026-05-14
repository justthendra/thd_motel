fx_version 'cerulean'
game 'gta5'

author 'Thendra'
description 'QBCore uyumlu meta anahtarlı motel sistemi'
lua54 'yes'

shared_scripts {
  'config.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/server.lua',
}

client_scripts {
  'client/client.lua',
}

dependencies {
  'qb-core',
  'ox_inventory',
  'qb-target',
  'qb-menu',
  'oxmysql',
}
