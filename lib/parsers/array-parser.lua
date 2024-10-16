---@description Parser for the `object` data type.
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function arrayParser(builder)
  return function(value)
    for index, item in ipairs(value) do
      local parsedValue, error = builder.metadata.element.parse(item)

      if (error) then
        return nil, {
          code = error.code,
          message = error.message,
          path = ("%s%s"):format(index, string.len(error.path) > 0 and (".%s"):format(error.path) or ""),
        }
      end

      value[index] = parsedValue
    end

    return value, nil
  end
end
