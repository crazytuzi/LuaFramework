local OctetsStream = require("netio.OctetsStream")
local WuShiInfo = class("WuShiInfo")
WuShiInfo.ON = 1
WuShiInfo.OFF = 2
WuShiInfo.ACTIVATE = 3
WuShiInfo.NOT_ACTIVATE = 4
function WuShiInfo:ctor(wuShiCfgId, isOn, isActivate, fragmentCount)
  self.wuShiCfgId = wuShiCfgId or nil
  self.isOn = isOn or nil
  self.isActivate = isActivate or nil
  self.fragmentCount = fragmentCount or nil
end
function WuShiInfo:marshal(os)
  os:marshalInt32(self.wuShiCfgId)
  os:marshalInt32(self.isOn)
  os:marshalInt32(self.isActivate)
  os:marshalInt32(self.fragmentCount)
end
function WuShiInfo:unmarshal(os)
  self.wuShiCfgId = os:unmarshalInt32()
  self.isOn = os:unmarshalInt32()
  self.isActivate = os:unmarshalInt32()
  self.fragmentCount = os:unmarshalInt32()
end
return WuShiInfo
