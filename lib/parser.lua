---@generic R
---@alias Parser fun(value: R): R, ValidationError | nil Parses the value

---@description Parser for a built validation chain
---@param builder ChainBuilder
---@diagnostic disable-next-line: lowercase-global
function validationParse(builder)
  ---@type Parser
  return function (value)
    if (not builder.metadata.required and value == nil) then
      return value, nil
    end

    if (value == nil) then
      return nil, {
        path = "",
        code = ValidationCodes.Required,
        message = builder.metadata.options.requiredErrorMessage or "Value is required",
      }
    end

    local correctedType = type(value) --[[@as PrimitiveType]]--
    
    -- Convert table to object or array
    if (
      (builder.metadata.type == "object" or builder.metadata.type == "array")
      and correctedType == "table"
    ) then
      correctedType = builder.metadata.type
    end

    -- Convert string to enum
    if (builder.metadata.type == "enum" and correctedType == "string") then
      correctedType = builder.metadata.type
    end

    if (builder.metadata.type ~= "union" and correctedType ~= builder.metadata.type) then
      return nil, {
        path = "",
        code = ValidationCodes.InvalidType,
        message = builder.metadata.options.invalidTypeMessage or ("Invalid type. Received: %s, expected: %s"):format(type(value), builder.metadata.type)
      }
    end

    local isValueAnArray = isArray(value)
    local valueType = type(value)

    -- Additional validation to check wether value is an actual array
    if (builder.metadata.type == "array") then
      if (not isValueAnArray) then
        return nil, {
          path = "",
          code = ValidationCodes.InvalidType,
          message = builder.metadata.options.invalidTypeMessage or ("Invalid type. Received: %s, expected: array"):format(valueType == "table" and "object" or valueType)
        }
      end
    end

    -- Additional validation to check wether value is an actual object
    if (builder.metadata.type == "object") then
      if (isValueAnArray and #value > 0) then
        return nil, {
          path = "",
          code = ValidationCodes.InvalidType,
          message = builder.metadata.options.invalidTypeMessage or ("Invalid type. Received: %s, expected: object"):format(valueType == "table" and "array" or valueType)
        }
      end
    end

    -- Union parser
    if (builder.metadata.type == "union") then
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
        message = builder.metadata.options.invalidTypeMessage or ("Invalid union. Received: %s, expected: %s"):format(valueType, table.concat(acceptedUnionTypes, ", "))
      }
    end

    -- Enum parser
    if (builder.metadata.type == "enum") then
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

    -- String and number parser
    if (
      builder.metadata.type == "string"
      or builder.metadata.type == "number"
      or builder.metadata.type == "array"
      and (builder.metadata.additional and #builder.metadata.additional > 0)
    ) then
      return alphanumericParser(builder)(value)
    end

    -- Array parser
    if (builder.metadata.type == "array") then
      if (builder.metadata.element == nil) then
        error("Element builder is not defined")
      end

      for index, field in ipairs(value) do
        local parsed, error = builder.metadata.element.parse(field)

        if (error) then
          return nil, {
            code = error.code,
            message = error.message,
            path = ("%s%s"):format(index, string.len(error.path) > 0 and (".%s"):format(error.path) or ""),
          }
        end

        value[index] = parsed
      end

      return value, nil
    end

    -- Object parser
    if (builder.metadata.type == "object") then
      if (type(builder.metadata.fields) ~= "table") then
        return value, nil
      end

      if (not builder.metadata.passUndefined) then
        for key in pairs(value) do
          if (builder.metadata.fields[key] == nil) then
            value[key] = nil
          end
        end
      end

      for key, fieldBuilder in pairs(builder.metadata.fields) do
        local parsed, error = fieldBuilder.parse(value[key])

        if (error) then
          return nil, {
            code = error.code,
            message = error.message,
            path = ("%s%s"):format(key, string.len(error.path) > 0 and (".%s"):format(error.path) or ""),
          }
        end

        value[key] = parsed
      end

      return value, nil
    end

    return value, nil
  end
end
