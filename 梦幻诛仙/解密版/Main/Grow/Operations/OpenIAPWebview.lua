local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenSpecialTrafficURL = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenSpecialTrafficURL.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  if _G.platform ~= _G.Platform.ios then
    Toast(textRes.Common[1111])
    return false
  end
  local url = params[1]
  if url == nil then
    Toast("URL can not be nil!")
    return false
  end
  local DeviceUtility = require("Utility.DeviceUtility")
  if not DeviceUtility.IsSupportMidasJSAPI() then
    Toast(textRes.Common[1110])
    return false
  end
  require("Main.ECGame").Instance():OpenUrlByZLBrowserWithPayInfo(url)
  return false
end
return OpenSpecialTrafficURL.Commit()
