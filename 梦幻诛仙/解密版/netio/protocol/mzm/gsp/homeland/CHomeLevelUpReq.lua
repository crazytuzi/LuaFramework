local CHomeLevelUpReq = class("CHomeLevelUpReq")
CHomeLevelUpReq.TYPEID = 12605442
function CHomeLevelUpReq:ctor(createType)
  self.id = 12605442
  self.createType = createType or nil
end
function CHomeLevelUpReq:marshal(os)
  os:marshalInt32(self.createType)
end
function CHomeLevelUpReq:unmarshal(os)
  self.createType = os:unmarshalInt32()
end
function CHomeLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CHomeLevelUpReq
