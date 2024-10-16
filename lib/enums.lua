---@enum ValidationCode
ValidationCodes = {
  Custom = "custom",
  TooBig = "too_big",
  Required = "required",
  TooSmall = "too_small",
  InvalidType = "invalid_type",
  InvalidEnum = "invalid_enum",
  InvalidUnion = "invalid_union",
}

---@enum AllowedPrimitiveBuilderType
AllowedPrimitiveBuilderTypes = {
  enum = "enum",
  array = "array",
  union = "union",
  string = "string",
  number = "number",
  object = "object",
  boolean = "boolean",
}
