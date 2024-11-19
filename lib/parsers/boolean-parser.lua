---@description Parser for the `boolean` data type.
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function booleanParser(builder)
  return function(value)
    if (type(value) ~= "boolean") then
      return nil, {
        path = "",
        code = ValidationCodes.InvalidType,
        message = builder.metadata.options.invalidTypeMessage or ("Invalid type. Received: %s, expected: boolean"):format(type(value))
      }
    end

    return value, nil
  end
end
