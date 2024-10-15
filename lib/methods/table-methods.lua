TableMethods = {}

---@param builder ChainBuilder
function TableMethods.passthrough(builder)
  return function()
    builder.metadata.passUndefined = true

    return builder
  end
end
