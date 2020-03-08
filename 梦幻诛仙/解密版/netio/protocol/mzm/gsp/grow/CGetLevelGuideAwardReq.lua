local CGetLevelGuideAwardReq = class("CGetLevelGuideAwardReq")
CGetLevelGuideAwardReq.TYPEID = 12596997
function CGetLevelGuideAwardReq:ctor(targetId)
  self.id = 12596997
  self.targetId = targetId or nil
end
function CGetLevelGuideAwardReq:marshal(os)
  os:marshalInt32(self.targetId)
end
function CGetLevelGuideAwardReq:unmarshal(os)
  self.targetId = os:unmarshalInt32()
end
function CGetLevelGuideAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetLevelGuideAwardReq
