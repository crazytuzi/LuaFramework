local type = type
local error = error
local string = string
local tostring = tostring
module("protobuf.type_checkers")
function TypeChecker(acceptable_types)
  local acceptable_types = acceptable_types
  return function(proposed_value)
    local t = type(proposed_value)
    if acceptable_types[type(proposed_value)] == nil then
      error(string.format("%s has type %s, but expected one of: %s", tostring(proposed_value), type(proposed_value), acceptable_types))
    end
  end
end
function Int32ValueChecker()
  local _MIN = -2147483648
  local _MAX = 2147483647
  return function(proposed_value)
    if type(proposed_value) ~= "number" then
      error(string.format("%s has type %s, but expected one of: number", tostring(proposed_value), type(proposed_value)))
    end
    if proposed_value < _MIN or proposed_value > _MAX then
      error("Value out of range: " .. proposed_value)
    end
  end
end
function Uint32ValueChecker(IntValueChecker)
  local _MIN = 0
  local _MAX = 4294967295
  return function(proposed_value)
    if type(proposed_value) ~= "number" then
      error(string.format("%s has type %s, but expected one of: number", tostring(proposed_value), type(proposed_value)))
    end
    if proposed_value < _MIN or proposed_value > _MAX then
      error("Value out of range: " .. proposed_value)
    end
  end
end
function UnicodeValueChecker()
  return function(proposed_value)
    if type(proposed_value) ~= "string" then
      error(string.format("%s has type %s, but expected one of: string", tostring(proposed_value), type(proposed_value)))
    end
  end
end
function Int64StringChecker()
  return function(proposed_value)
    if type(proposed_value) ~= "string" then
      error(string.format("%s has type %s, but expected one of: string", tostring(proposed_value), type(proposed_value)))
    end
    if #proposed_value ~= 8 then
      error(string.format("%s has length %s, but expected: 8", #proposed_value))
    end
  end
end
