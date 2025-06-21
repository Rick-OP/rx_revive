fx_version 'cerulean'
games { 'gta5' }

author 'RICK-OP'
description 'A simple revive Script'
version 'v2.0'

lua54 'yes'

dependency 'ox_lib'

shared_script {
    '@ox_lib/init.lua'
}

client_script 'client.lua'

server_script 'server.lua'
