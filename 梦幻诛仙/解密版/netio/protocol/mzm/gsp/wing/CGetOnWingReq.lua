local CGetOnWingReq = class("CGetOnWingReq")
CGetOnWingReq.TYPEID = 12596530
function CGetOnWingReq:ctor(cfgId)
  self.id = 12596530
  self.cfgId = cfgId or nil
end
function CGetOnWingReq:marshal(os)
  os:marshalInt32(self.cfgId)
end
function CGetOnWingReq:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
end
function CGetOnWingReq:sizepolicy(size)
  return size <= 65535
end
return CGetOnWingReq
