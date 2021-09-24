local function validate_number(value)
    return type(value) == "number"
end

local function validate_required(value)
    if not value or value == "" then 
        return false 
    end

    return true
end

local function validate_table(value)
    return type(value) == "table"
end

local function validate_string(value)
    return type(value) == "string"
end

local function validate_between(value,parameters)
    return value >= parameters[1] and value <= parameters[2]
end

local function validate_max(value,parameters)
    return value <= parameters[1]
end

local function validate_min(value,parameters)
    return value >= parameters[1]
end

local function validate_boolean(value)
    return type(value) == "boolean"
end

local methods = {
  ["required"] = validate_required, 
  ["number"] = validate_number, 
  ["string"] = validate_string, 
  ["table"] = validate_table,
  ["between"] = validate_between,
  ["max"] = validate_max,
  ["min"] = validate_min,
  ["boolean"] = validate_boolean,
}

local Validator = {}
setmetatable(Validator, {__index = methods})

return Validator