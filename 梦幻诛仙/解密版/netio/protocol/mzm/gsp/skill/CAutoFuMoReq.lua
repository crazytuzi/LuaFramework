local CAutoFuMoReq = class("CAutoFuMoReq")
CAutoFuMoReq.TYPEID = 12591624
function CAutoFuMoReq:ctor(skillId, skillBagId)
  self.id = 12591624
  self.skillId = skillId or nil
  self.skillBagId = skillBagId or nil
end
function CAutoFuMoReq:marshal(os)
  os:marshalInt32(self.skillId)
  os:marshalInt32(self.skillBagId)
end
function CAutoFuMoReq:unmarshal(os)
  self.skillId = os:unmarshalInt32()
  self.skillBagId = os:unmarshalInt32()
end
function CAutoFuMoReq:sizepolicy(size)
  return size <= 65535
end
return CAutoFuMoReq
