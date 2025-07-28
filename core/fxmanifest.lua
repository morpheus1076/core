fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games        { 'rdr3', 'gta5' }

name 'core'
author 'morpheus1076'
description 'framework core'
version '1.0.0'

ui_page 'html/hud.html'

files
{
    'html/hud.html',
    'html/hud.css',
    'html/hud.js',
    'html/fonds/*.*',
    'html/images/*.*',
    'html/sounds/*.*',
    'shared/*.lua',
    'images/*.*',
    'locales/*.json'
}

shared_script
{
    '@ox_core/lib/init.lua',
    'shared/*.lua',
}

server_script
{
    '@oxmysql/lib/MySQL.lua',
    'server/sv_callbacks.lua',
    'server/sv_lib.lua',
    'server/sv_core.lua',
    'server/sv_hud.lua',
    'server/menu/*.lua',
    'server/features/*.lua',
    'server/housing/*.lua',
}

client_script
{
    'client/cl_lib.lua',
    'client/cl_core.lua',
    'client/cl_hud.lua',
    'client/cl_proptweaks.lua',
    'client/menu/*.lua',
    'client/features/*.lua',
    'client/housing/*.lua',
}
