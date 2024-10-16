---@param code string The error code that was caused by the invalid builder
---@diagnostic disable-next-line: lowercase-global
function throwInvalidBuilderError(code)
  error(([[
    
    Code: %s

    Message:
      Failed to validate the provided builder. This is likely due to a misconfiguration
      in the validation chain. Please check the validation chain and ensure that it is
      setup correctly.

      If setup correctly, please open an issue at `https://github.com/aquapha/lua-vBuilder-fivem/issues/new`
      with the validation chain that caused this error and the error code.
  ]]):format(code))
end

---@description Checks whether the provided builder is valid
---@param builder ChainBuilder
---@diagnostic disable-next-line: lowercase-global
function validateBuilder(builder)
  if (type(builder) ~= "table") then
    throwInvalidBuilderError("invalid_builder_type")
  end

  if (type(builder.metadata) ~= "table") then
    throwInvalidBuilderError("invalid_builder_metadata_type")
  end

  for _, allowedPrimitiveBuilderType in pairs(AllowedPrimitiveBuilderTypes) do
    if (builder.metadata.type == allowedPrimitiveBuilderType) then
      return
    end
  end

  throwInvalidBuilderError("invalid_builder_primitive_type")
end
