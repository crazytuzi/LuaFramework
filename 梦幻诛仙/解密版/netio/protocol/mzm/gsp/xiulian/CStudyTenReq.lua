local CStudyTenReq = class("CStudyTenReq")
CStudyTenReq.TYPEID = 793092
function CStudyTenReq:ctor(skillBagId)
  self.id = 793092
  self.skillBagId = skillBagId or nil
end
function CStudyTenReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CStudyTenReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CStudyTenReq:sizepolicy(size)
  return size <= 65535
end
return CStudyTenReq
