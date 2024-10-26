fx_version 'cerulean'
game 'gta5'

author 'BibiModz'
description 'Script de vol à l\'arraché avec ox_target'
version '1.0.0'

client_scripts {
    'config.lua', 
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua', 
    'config.lua', 
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua'
}


dependencies {
    'ox_target', 
    'ox_lib',    
    'es_extended' 
}

lua54 'yes'