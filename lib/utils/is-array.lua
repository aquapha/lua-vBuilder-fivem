---@description Checks whether the provided value is an array
---@param value any
---@return boolean
---@diagnostic disable-next-line: lowercase-global
function isArray(value)
  if (type(value) ~= "table") then return false end

  for key, _ in pairs(value) do
    if (type(key) ~= "number") then return false end
  end

  return true
end
