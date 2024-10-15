fx_version 'cerulean'
games { 'gta5', 'rdr3' }
lua54 'yes'

name 'vBuilder'
author 'aquapha'
version '1.0.0'
description 'A validation builder for lua'

shared_scripts {
  'lib/utils/*.lua',

  'lib/enums.lua',
  'lib/generator.lua',
  'lib/parser.lua',

  'lib/methods/primitive-methods.lua',
  'lib/methods/table-methods.lua',

  'lib/primitive-builders.lua',
}
