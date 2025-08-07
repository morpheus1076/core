fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games        { 'rdr3', 'gta5' }

name 'mor_tuning'
author 'morpheus1076'
description 'Vehicle Tuning'
version '1.0.0'

files
{
    'shared/*.lua',
}

shared_script
{
    "@ox_lib/init.lua",
    'shared/*.lua',
}

client_script
{
    'shared/*.lua',
    'client/*.lua',

}

server_script
{
    'shared/*.lua',
    'server/*.lua',
    "@oxmysql/lib/MySQL.lua",
}