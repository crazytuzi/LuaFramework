local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VersionKeyPolicy = import(".VersionKeyPolicy")
local EfunTWHKPolicy = Lplus.Extend(VersionKeyPolicy, MODULE_NAME)
local def = EfunTWHKPolicy.define
def.const("number").KEY_TW_IOS = 2
def.const("number").KEY_TW_ANDROID = 3
def.const("number").KEY_HK_IOS = 4
def.const("number").KEY_HK_ANDROID = 5
def.override("=>", "number").GetResourceVersionKey = function(self)
  local ECUniSDK = require("ProxySDK.ECUniSDK")
  local channelType = ECUniSDK.Instance():GetChannelType()
  if channelType == ECUniSDK.CHANNELTYPE.EFUNTW then
    if _G.platform == Platform.ios then
      return EfunTWHKPolicy.KEY_TW_IOS
    elseif _G.platform == Platform.android then
      return EfunTWHKPolicy.KEY_TW_ANDROID
    else
      error("platform error: " .. tostring(_G.platform))
    end
  elseif channelType == ECUniSDK.CHANNELTYPE.EFUNHK then
    if _G.platform == Platform.ios then
      return EfunTWHKPolicy.KEY_HK_IOS
    elseif _G.platform == Platform.android then
      return EfunTWHKPolicy.KEY_HK_ANDROID
    else
      error("platform error: " .. tostring(_G.platform))
    end
  else
    error("channelType error: " .. tostring(channelType))
  end
end
return EfunTWHKPolicy.Commit()
