---@description Parser for the `union` data type.
---@param builder ChainBuilder
---@return Parser
---@diagnostic disable-next-line: lowercase-global
function unionParser(builder)
  return function(value)
    ---@type ValidationError[]
    local unionErrors = {}
    ---@type PrimitiveType[]
    local acceptedUnionTypes = {}

    for _, unionBuilder in ipairs(builder.metadata.unionBuilders) do
      local parsed, unionError = unionBuilder.parse(value)

      if (parsed) then
        return parsed, nil
      end

      table.insert(unionErrors, unionError)
      table.insert(acceptedUnionTypes, unionBuilder.metadata.type)
    end

    -- If all errors are type errors, it means that the value is not a valid union
    for _, unionError in ipairs(unionErrors) do
      if (unionError.code ~= ValidationCodes.InvalidType) then
        return nil, unionError
      end
    end

    return nil, {
      path = "",
      code = ValidationCodes.InvalidUnion,
      message = builder.metadata.options.invalidTypeMessage or ("Invalid union. Received: %s, expected: %s"):format(type(value), table.concat(acceptedUnionTypes, ", "))
    }
  end
end
