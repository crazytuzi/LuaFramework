local Lplus = require("Lplus")
local MultiOccupationUtils = Lplus.Class("MultiOccupationUtils")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local instance
local def = MultiOccupationUtils.define
def.static("=>", MultiOccupationUtils).Instance = function()
  if nil == instance then
    instance = MultiOccupationUtils()
  end
  return instance
end
def.method("number", "=>", "string").MakeTimeStr = function(self, time)
  if time < 0 then
    return string.format(textRes.MultiOccupation[18], 0)
  end
  local hour = math.modf(time / 3600)
  local min = math.modf((time - hour * 3600) / 60)
  local sec = time - hour * 3600 - min * 60
  local ret = ""
  local strHour = string.format(textRes.MultiOccupation[16], hour)
  local strMin = string.format(textRes.MultiOccupation[17], min)
  local strSec = string.format(textRes.MultiOccupation[18], sec)
  if hour > 0 then
    return strHour .. strMin .. strSec
  elseif min > 0 then
    return strMin .. strSec
  else
    return strSec
  end
end
def.method("number", "=>", "boolean").IsOccupationHided = function(self, occupation)
  return not _G.IsOccupationOpen(occupation)
end
MultiOccupationUtils.Commit()
return MultiOccupationUtils
