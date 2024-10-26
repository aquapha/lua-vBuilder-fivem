<img src="https://i.imgur.com/VW17b7j.png" style="display: block; margin: 0 auto; margin-bottom: 40px;" />

# vBuilder - Data validation builder

`vBuilder` ( validationBuilder ) is a tool that is focused on building validation schemas to ensure that the data received matches a specific specification.

## Setup

This resource exposes an initialization file, to use it, simply add the following to your `fxmanifest.lua` file:

```lua
shared_scripts {
  '@lua-vBuilder-fivem/init.lua',
}
```

## Supported data types

- Arrays: `vBuilder:array(ChainBuilder, CustomOptions | nil)`
- Objects: `vBuilder:object(table<string, ChainBuilder>, CustomOptions | nil)`
- Strings: `vBuilder:string(CustomOptions | nil)`
- Numbers: `vBuilder:number(CustomOptions | nil)`
- Enums: `vBuilder:enum(string[], CustomOptions | nil)`
- Unions: `vBuilder:union(ChainBuilder[], CustomOptions | nil)`

## Naming

- `ChainBuilder` - The builder that is generated from a initial data type builder `vBuilder:string()` will generate a specific `StringChainBuilder`
- `CustomOptions` - Custom options for invalid error messages `(table)`
  - `invalidTypeMessage` - Message displayed when a values type doesn't match
  - `requiredErrorMessage` - Message displayed when a value is `nil` but required
- `ValidationError` - A table that is composed of values that indicate what error occurred
  - `path` - The path to the field that failed
  - `message` - The error message
  - `code` An enum code for that specific error

## Additional validation methods

- `min(number, CustomOptions | nil)`
  - `number` Indicates the lowest amount of the value for it to be valid:
    - Number - Size
    - String - Length of string
    - Array - Length of elements
- `max(number, CustomOptions | nil)`
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

local validPlayer <const> = { ssn = "123456789" }
local invalidPlayer <const> = { ssn = nil } -- Or {}

local validParsed <const>, validError <const> = playerValidation.parse(validPlayer)
local invalidParsed <const>, invalidError <const> = playerValidation.parse(invalidPlayer)

-- ✅ Passes the validation
print(json.encode(validParsed)) -- { ssn = "123456789 }
print(json.encode(validError)) -- nil

-- ❌ Fails the validation
print(json.encode(invalidParsed)) -- nil
print(json.encode(invalidError)) -- { code = "required", message = "Value is required", }
```

### Enum validation

```lua
local playerJobEnum <const> = vBuilder:enum({ "Police", "Firefighter", "Doctor" })

local validJob <const> = playerJobEnum.parse("Police")
print(validJob) -- "Police

local _, invalidJobError <const> = playerJobEnum.parse("Teacher")
print(json.encode(invalidJobError)) -- { code = "invalid_enum", message = "Value is not a valid enum", path = "" }

-- It is case sensitive, meaning that "police, POLICE, pOlIcE, ...etc" will fail the validation
```

### Union validation

#### Caveats

1. Cannot be used within an array: `vBuilder:array(vBuilder:union(...))`. This is due to the fact that the array builder expects a single type and not a union of types.

```lua
local playerJobNameOrIdUnion <const> = vBuilder:union({
  vBuilder:string(),
  vBuilder:number(),
})

local validString <const> = playerJobNameOrIdUnion.parse("Police")
print(validString) -- "Police"

local validNumber <const> = playerJobNameOrIdUnion.parse(123)
print(validNumber) -- 123

local _, invalidError <const> = playerJobNameOrIdUnion.parse({})
print(json.encode(invalidError)) -- { code = "invalid_union", message = "Invalid union. Received: table, expected: string, number", path = "" }
```

### Methods `.min, .max, .optional`

```lua
local playerNameValidation <const> = vBuilder:string().min(1).max(10)

-- ✅ Passes the validation since it is more than 1 characted and less than 10
local valid = playerNameValidation.parse("John")
-- ❌ Fails the validation since it is more than 10
local _, longError = playerNameValidation.parse("John The Mighty")
-- ❌ Fails the validation since it is less than 1
local _, shortError = playerNameValidation.parse("")
-- ❌ Fails the validation since it is nil
local _, nilError = playerNameValidation.parse(nil)

-- If you wish to allow nil values, you can simply append the `.optional()` method
-- Or do if from the start of the validation builder
-- ✅ Passes the validation since nil is allowed
local validNil <const> = playerNameValidation.optional().parse(nil)
-- Or
local playerNilNameValidation <const> = vBuilder:string().min(1).max(10).optional()
local validNewNil <const> = playerNilNameValidation.parse(nil)
```

### Method `.passthrough`

```lua
local playerValidation <const> = vBuilder:object({
	name = vBuilder:string().min(1).max(10),
})

-- Will remove the `job` field since it is not present in the schema
local nonPassthroughParsed <const> = playerValidation.parse({
	name = "John",
	job = "Police",
})
print(json.encode(nonPassthroughParsed)) -- { name = "John" }

-- Will keep the `job` field since `.passthrough()` is appended.
local passthroughParsed <const> = playerValidation.passthrough().parse({
	name = "John",
	job = "Police",
})
print(json.encode(passthroughParsed)) -- { name = "John", job = "Police" }
```

### Custom error options

```lua
local playerValidation <const> = vBuilder:object({
  name = vBuilder:string({
    requiredErrorMessage = "Name is required",
    invalidTypeMessage = "Name must be a string",
  }),
})

local _, typeError <const> = playerValidation.parse({ name = 123 })
print(json.encode(typeError)) -- { code = "invalid_type", message = "Name must be a string", path = "" }

local _, requiredError <const> = playerValidation.parse({})
print(json.encode(requiredError)) -- { code = "required", message = "Name is required", path = ""}
```

## Contribution

Issues are encouraged, this was only a small module that I created to safely mutate data in the database without breaking changes and if more custom functionality is needed, please create an issue for it. I will occasionally update this module with more features and improvements.
