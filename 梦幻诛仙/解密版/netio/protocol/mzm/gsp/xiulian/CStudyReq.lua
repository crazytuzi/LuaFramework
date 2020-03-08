local CStudyReq = class("CStudyReq")
CStudyReq.TYPEID = 793096
function CStudyReq:ctor(skillBagId)
  self.id = 793096
  self.skillBagId = skillBagId or nil
end
function CStudyReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CStudyReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CStudyReq:sizepolicy(size)
  return size <= 65535
end
return CStudyReq
