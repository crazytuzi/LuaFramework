local SPutOnWuShiSuccess = class("SPutOnWuShiSuccess")
SPutOnWuShiSuccess.TYPEID = 12618780
function SPutOnWuShiSuccess:ctor(wuShiCfgId)
  self.id = 12618780
  self.wuShiCfgId = wuShiCfgId or nil
end
function SPutOnWuShiSuccess:marshal(os)
  os:marshalInt32(self.wuShiCfgId)
end
function SPutOnWuShiSuccess:unmarshal(os)
  self.wuShiCfgId = os:unmarshalInt32()
end
function SPutOnWuShiSuccess:sizepolicy(size)
  return size <= 65535
end
return SPutOnWuShiSuccess
