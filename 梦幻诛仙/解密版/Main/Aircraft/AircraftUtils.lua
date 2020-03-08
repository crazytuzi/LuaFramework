local Lplus = require("Lplus")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local AircraftUtils = Lplus.Class("AircraftUtils")
local def = AircraftUtils.define
def.static("table", "=>", "string").GetAircraftAttrString = function(aircraftCfg)
  if aircraftCfg and aircraftCfg.props and #aircraftCfg.props > 0 then
    local result = ""
    local propCount = #aircraftCfg.props
    for i = 1, propCount do
      local prop = aircraftCfg.props[i]
      result = result .. AircraftUtils.GetAttrString(prop.propType, prop.propValue)
      if i ~= propCount then
        result = result .. "\n"
      end
    end
    return result
  else
    return textRes.Aircraft.AIRCRAFT_ATTR_NONE
  end
end
def.static("number", "number", "=>", "string").GetAttrString = function(propType, propValue)
  local result = ":+"
  local attrName = AircraftUtils.GetPropName(propType)
  if attrName then
    result = attrName .. result
  end
  result = result .. propValue
  return result
end
def.static("number", "=>", "string").GetPropName = function(propType)
  local attrName = textRes.Aircraft.PropertyName[propType]
  if nil == attrName then
    attrName = EquipModule.GetAttriName(propType)
  end
  return attrName
end
AircraftUtils.Commit()
return AircraftUtils
