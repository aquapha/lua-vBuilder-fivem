--- Only allow Lua 5.4
if (not _VERSION:find("5.4")) then
  error("^1Lua 5.4 must be enabled in the resource manifest!^0", 2)
end

local lua_vBuilder_fivem = "lua-vBuilder-fivem"
local resourceName = GetCurrentResourceName()

--- Avoid initializing the module if it's within itself
if (resourceName == lua_vBuilder_fivem) then
  return
end

if (GetResourceState(lua_vBuilder_fivem) ~= "started") then
  error("^1lua-vBuilder-fivem must be started before this resource.^0", 0)
end

local LoadResourceFile = LoadResourceFile

--- Must be manually updated
local moduleRoutes = {
  "lib/utils/is-array.lua",
  "lib/utils/validate-builder.lua",

  "lib/enums.lua",
  "lib/generator.lua",
  "lib/parsers/alphanumeric-parser.lua",
  "lib/parsers/boolean-parser.lua",
  "lib/parsers/array-parser.lua",
  "lib/parsers/enum-parser.lua",
  "lib/parsers/object-parser.lua",
  "lib/parsers/union-parser.lua",
  "lib/parser.lua",

  "lib/methods/primitive-methods.lua",
  "lib/methods/table-methods.lua",

  "lib/primitive-builders.lua",
}

---@param module string
local function loadModule(module)
  local chunk = LoadResourceFile(lua_vBuilder_fivem, module)

  if (not chunk) then return end

  local fun, err = load(chunk, ('@@lua-vBuilder-fivem/%s'):format(module))

  if (not fun or err) then
    return error(('\n^1Error importing module (%s): %s^0'):format(module, err), 3)
  end

  fun()
end

for i = 1, #moduleRoutes do
  local name = moduleRoutes[i]

  loadModule(name)
end
