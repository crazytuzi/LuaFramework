local CRpWingContentReq = class("CRpWingContentReq")
CRpWingContentReq.TYPEID = 12596527
function CRpWingContentReq:ctor(cfgId, rpType)
  self.id = 12596527
  self.cfgId = cfgId or nil
  self.rpType = rpType or nil
end
function CRpWingContentReq:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalUInt8(self.rpType)
end
function CRpWingContentReq:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.rpType = os:unmarshalUInt8()
end
function CRpWingContentReq:sizepolicy(size)
  return size <= 65535
end
return CRpWingContentReq
