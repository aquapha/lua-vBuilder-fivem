# vBuilder - Data validation builder

`vBuilder` ( validation Builder ) is a tool that is focused on building validation schemas to ensure that the data received matches a specific specification.

## Supported data types

- Arrays: `vBuilder:array(ChainBuilder[])`
- Objects: `vBuilder:object(table<string, ChainBuilder>)`
- Strings: `vBuilder:string()`
- Numbers: `vBuilder:number()`
- Enums: `vBuilder:enum(string[])`

## Naming

- `ChainBuilder` - The builder that is generated from a initial data type builder `vBuilder:string()` will generate a specific `StringChainBuilder`
- `CustomOptions` - Custom options for invalid error messages `(table)`
  - `invalidTypeMessage` - Message displayed when a values type doesn't match
  - `requiredErrorMessage` - Message displayed when a value is `nil` but required
- `ValidationError` - A table that is composed of values that indicate what error occurred
  - `path` - The path to the field that failed
  - `message` - The error message
  - `code` An enum code for that specific error
  -

## Additional validation methods

- `min(number, CustomOptions)`
  - `number` Indicates the lowest amount of the value for it to be valid:
    - Number - Size
    - String - Length of string
    - Array - Length of elements
- `max(number, CustomOptions)`
  - `number` - Indicates the highest amount of the value for it to be valid:
    - Number - Size
    - String - Length of string
    - Array - Length of elements
- `passthrough()` - Allows unspecified values in the schema to be passed through
  - By default this is set to `false`
  - Allowed on data types:
    1. `object`
- `optional()` - Allows the value to be `nil`
  - By default this is set to false
  - Allowed on all data types
- `parse(value): value | nil, ValidationError | nil` - Parses the provided value and either returns it or the validation error that occured

## Usage

### Basic value object validation

```lua
local playerValidation <const> = vBuilder:object({
	ssn = vBuilder:string()
})

local validPlayer = { ssn = "123456789" }
local invalidPlayer = { ssn = nil } -- Or {}

local validParsed, validError = playerValidation.parse(validPlayer)
local invalidParsed, invalidError = playerValidation.parse(invalidPlayer)

-- ✅ Passes the validation
print(json.encode(validParsed)) -- { ssn = "123456789 }
print(json.encode(validError)) -- nil

-- ❌ Passes the validation
print(json.encode(invalidParsed)) -- nil
print(json.encode(invalidError)) -- { code = "required", message = "Value is required", }
```

### Methods `.min, .max, .optional`

```lua
local playerNameValidation = vBuilder:string().min(1).max(10)

-- ✅ Passes the validation since it is more than 1 characted and less than 10
local valid = playerNameValidation.parse("John")
-- ❌ Fails the validation since it is more than 10
local invalidLong = playerNameValidation.parse("John The Mighty")
-- ❌ Fails the validation since it is less than 1
local invalidShort = playerNameValidation.parse("")
-- ❌ Fails the validation since it is nil
local invalidNil = playerNameValidation.parse(nil)

-- If you wish to allow nil values, you can simply append the `.optional()` method
-- Or do if from the start of the validation builder
-- ✅ Passes the validation since nil is allowed
local validNil = playerNameValidation.optional().parse(nil)
-- Or
local playerNilNameValidation = vBuilder:string().min(1).max(10).optional()
local validNewNil = playerNilNameValidation.parse(nil)
```

### Method `.passthrough`

```lua
local playerValidation = vBuilder:object({
	name = vBuilder:string().min(1).max(10),
})

-- Will remove the `job` field since it is not present in the schema
local nonPassthroughParsed = playerValidation.parse({
	name = "John",
	job = "Police",
})
print(json.encode(nonPassthroughParsed)) -- { name = "John" }

-- Will keep the `job` field since `.passthrough()` is appended.
local passthroughParsed = playerValidation.passthrough().parse({
	name = "John",
	job = "Police",
})
print(json.encode(passthroughParsed)) -- { name = "John", job = "Police" }
```

## Contribution

Issues and PR's are accepted and encouraged, this was only a small module that I created to safely mutate data in the database without breaking changes and if more custom functionality is needed, please create a PR for it.
