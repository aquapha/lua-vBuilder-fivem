---@param options CustomOptions | nil
function vBuilder:string(options)
  ---@class StringChainBuilder: ChainBuilder
  ---@field min fun(min: number, errorMessage: ErrorMessage): StringChainBuilder Enforces a minimum value for a string
  ---@field max fun(max: number, errorMessage: ErrorMessage): StringChainBuilder Enforces a maximum value for a string
  ---@field optional fun(): StringChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "string"
  builder.metadata.required = true
  builder.metadata.additional = {}
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end

---@param options CustomOptions | nil
function vBuilder:number(options)
  ---@class NumberChainBuilder: ChainBuilder
  ---@field min fun(min: number, errorMessage: ErrorMessage): NumberChainBuilder Enforces a minimum value for a number
  ---@field max fun(max: number, errorMessage: ErrorMessage): NumberChainBuilder Enforces a maximum value for a number
  ---@field optional fun(): NumberChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "number"
  builder.metadata.required = true
  builder.metadata.additional = {}
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end

---@param enums string[]
---@param options CustomOptions | nil
function vBuilder:enum(enums, options)
  if (type(enums) ~= "table" or not isArray(enums) or #enums <= 0) then
    error("Options must be a non-empty array")
  end

  ---@class EnumChainBuilder: ChainBuilder
  ---@field optional fun(): EnumChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "enum"
  builder.metadata.enums = enums
  builder.metadata.required = true
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  
  return builder
end

---@param options CustomOptions | nil
function vBuilder:boolean(options)
  ---@class BooleanChainBuilder: ChainBuilder
  ---@field optional fun(): BooleanChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.required = true
  builder.metadata.type = "boolean"
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end

---@param fields table<string, ChainBuilder>
---@param options CustomOptions | nil
function vBuilder:object(fields, options)
  if (type(fields) ~= "table" or (isArray(fields) and #fields > 0)) then
    error("Fields must be a table")
  end

  ---@class ObjectChainBuilder: ChainBuilder
  ---@field passthrough fun(): ObjectChainBuilder Allows values that don't exist in the schema to pass through
  ---@field optional fun(): ObjectChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "object"
  builder.metadata.required = true
  builder.metadata.fields = fields
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  builder.passthrough = TableMethods.passthrough(builder)

  return builder
end

---@param element ChainBuilder
---@param options CustomOptions | nil
function vBuilder:array(element, options)
  if (type(element) ~= "table") then
    error("Element must be a ChainBuilder")
  end

  -- Don't allow unions in arrays
  if (element.metadata.type == "union") then
    error("Unions are not allowed in arrays")
  end

  ---@class ArrayChainBuilder: ChainBuilder
  ---@field optional fun(): ArrayChainBuilder Accepts a nil value
  ---@field min fun(min: number, errorMessage: ErrorMessage): ArrayChainBuilder Enforces a minimum length for an array
  ---@field max fun(max: number, errorMessage: ErrorMessage): ArrayChainBuilder Enforces a maximum length for an array
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "array"
  builder.metadata.additional = {}
  builder.metadata.required = true
  builder.metadata.element = element
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end

---@param builders ChainBuilder[]
---@param options CustomOptions | nil
function vBuilder:union(builders, options)
  if (type(builders) ~= "table" or not isArray(builders)) then
    error("Builders must be an array")
  end

  ---@class UnionChainBuilder: ChainBuilder
  ---@field optional fun(): UnionChainBuilder Accepts a nil value
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = "union"
  builder.metadata.required = true
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}
  builder.metadata.unionBuilders = builders

  builder.parse = validationParse(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end
