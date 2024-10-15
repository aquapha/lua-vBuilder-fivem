PrimitiveMethods = {}

---@param builder ChainBuilder
function PrimitiveMethods.min(builder)
  ---@description Enforces a minimum value for a string or number
  ---@param minimum number The minimum value
  ---@param errorMessage ErrorMessage The error message to be returned when the validation fails
  return function(minimum, errorMessage)
    if (type(minimum) ~= "number") then
      error("Minimum value must be a number")
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function (value)
        local length = 0

        if (builder.metadata.type == "string") then
          length = string.len(value)
        end

        if (builder.metadata.type == "number") then
          length = value
        end

        if (builder.metadata.type == "array") then
          length = #value
        end

        if (length < minimum) then
          return {
            path = "",
            code = ValidationCodes.TooSmall,
            message = errorMessage or ("Invalid minimum length. Received %s, expected: %s"):format(length, minimum),
          }
        end

        return true
      end
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.max(builder)
  return function(maximum, errorMessage)
    if (type(maximum) ~= "number") then
      error("Maximum value must be a number")
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function (value)
        local length = 0

        if (builder.metadata.type == "string") then
          length = string.len(value)
        end

        if (builder.metadata.type == "number") then
          length = value
        end

        if (builder.metadata.type == "array") then
          length = #value
        end

        if (length > maximum) then
          return {
            path = "",
            code = ValidationCodes.TooBig,
            message = errorMessage or ("Invalid maximum length. Received %s, expected: %s"):format(length, maximum),
          }
        end

        return true
      end
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.optional(builder)
  return function()
    builder.metadata.required = false

    return builder
  end
end
