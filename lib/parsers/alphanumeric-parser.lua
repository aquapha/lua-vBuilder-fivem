---@description Parser for the `string` and `number` data types. (alphanumeric)
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function alphanumericParser(builder)
  return function(value)
    for _, additionalParser in ipairs(builder.metadata.additional) do
      local valueOrError = additionalParser.validate(value)

      if (type(valueOrError) == "table") then
        return nil, valueOrError
      end
    end

    return value, nil
  end
end
