---@description Parser for the `object` data type.
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function objectParser(builder)
  return function(value)
    if (not builder.metadata.passUndefined) then
      for key in pairs(value) do
        if (builder.metadata.fields[key] == nil) then
          value[key] = nil
        end
      end
    end

    for key, fieldBuilder in pairs(builder.metadata.fields) do
      local parsedValue, error = fieldBuilder.parse(value[key])

      if (error) then
        return nil, {
          code = error.code,
          message = error.message,
          path = ("%s%s"):format(key, string.len(error.path) > 0 and (".%s"):format(error.path) or ""),
        }
      end

      value[key] = parsedValue
    end

    return value, nil
  end
end
