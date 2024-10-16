---@description Parser for the `enum` data type.
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function enumParser(builder)
  return function(value)
    for _, enumValue in ipairs(builder.metadata.enums) do
      if (enumValue == value) then
        return value, nil
      end
    end

    return nil, {
      path = "",
      code = ValidationCodes.InvalidEnum,
      message = builder.metadata.options.invalidTypeMessage or ("Invalid enum. Received: %s, expected: %s"):format(value, table.concat(builder.metadata.enums, ", "))
    }
  end
end
