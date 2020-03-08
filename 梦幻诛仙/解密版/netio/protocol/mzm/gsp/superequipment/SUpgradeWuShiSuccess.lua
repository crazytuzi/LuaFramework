local SUpgradeWuShiSuccess = class("SUpgradeWuShiSuccess")
SUpgradeWuShiSuccess.TYPEID = 12618775
function SUpgradeWuShiSuccess:ctor(wuShiCfgId, lastWuShiCfgId, fragmentCount, isActivate)
  self.id = 12618775
  self.wuShiCfgId = wuShiCfgId or nil
  self.lastWuShiCfgId = lastWuShiCfgId or nil
  self.fragmentCount = fragmentCount or nil
  self.isActivate = isActivate or nil
end
function SUpgradeWuShiSuccess:marshal(os)
  os:marshalInt32(self.wuShiCfgId)
  os:marshalInt32(self.lastWuShiCfgId)
  os:marshalInt32(self.fragmentCount)
  os:marshalInt32(self.isActivate)
end
function SUpgradeWuShiSuccess:unmarshal(os)
  self.wuShiCfgId = os:unmarshalInt32()
  self.lastWuShiCfgId = os:unmarshalInt32()
  self.fragmentCount = os:unmarshalInt32()
  self.isActivate = os:unmarshalInt32()
end
function SUpgradeWuShiSuccess:sizepolicy(size)
  return size <= 65535
end
return SUpgradeWuShiSuccess
