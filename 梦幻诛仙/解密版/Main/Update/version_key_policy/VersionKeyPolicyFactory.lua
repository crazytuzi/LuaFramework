local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VersionKeyPolicyFactory = Lplus.Class(MODULE_NAME)
local VersionKeyPolicy = import(".VersionKeyPolicy")
local def = VersionKeyPolicyFactory.define
def.static("=>", VersionKeyPolicy).Create = function()
  local policyClass
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    local channelType = ECUniSDK.Instance():GetChannelType()
    if channelType == ECUniSDK.CHANNELTYPE.EFUNTW or channelType == ECUniSDK.CHANNELTYPE.EFUNHK then
      policyClass = import(".EfunTWHKPolicy", MODULE_NAME)
    end
  end
  if policyClass == nil then
    policyClass = import(".DefaultPolicy", MODULE_NAME)
  end
  local policy = policyClass()
  return policy
end
return VersionKeyPolicyFactory.Commit()
