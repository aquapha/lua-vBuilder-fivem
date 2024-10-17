-- Root class for the validation builder

---@alias ErrorMessage string | nil
---@alias PrimitiveType "string" | "number" | "object" | "array" | "boolean" | "enum" | "union"
---@alias ValidationMethod fun(value: any): boolean | ValidationError The function to validate the value, if string is returned, the validation failed

---@class CustomOptions The custom options for the validation
---@field invalidTypeMessage ErrorMessage The message to be returned when the validation fails
---@field requiredErrorMessage ErrorMessage The message to be returned when the field is required and not present

---@class PrimitiveMetadata The metadata for the primitive validation
---@field type PrimitiveType The type of the validation
---@field required boolean Whether the field is required or not
---@field options CustomOptions | nil The custom options for the validation
---@field fields table<string, ChainBuilder> | nil The fields of the object
---@field passUndefined boolean Whether to passthrough fields that have not been defined
---@field additional Validation[] | nil The additional validations to be used
---@field element ChainBuilder | nil The element of the array
---@field enums string[] | nil The enums for the validation
---@field unionBuilders ChainBuilder[] | nil The builders for the union

---@class Validation
---@field validate ValidationMethod

---@class ValidationError
---@field path string The field path that failed the validation
---@field message string The message of the validation error
---@field code ValidationCode The code of the validation error

---@class ChainBuilder
---@field metadata PrimitiveMetadata The metadata for the primitive validation
---@field parse Parser Parses the value

---@class PrimitiveBuilder
---@field metadata PrimitiveMetadata The metadata for the primitive validation
vBuilder = {}

-- Register an export if the script is running on the client
exports("vBuilder", function()
  return vBuilder
end)
