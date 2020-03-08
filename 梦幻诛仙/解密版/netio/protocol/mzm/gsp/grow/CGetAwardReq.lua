local CGetAwardReq = class("CGetAwardReq")
CGetAwardReq.TYPEID = 12596995
function CGetAwardReq:ctor(targetId)
  self.id = 12596995
  self.targetId = targetId or nil
end
function CGetAwardReq:marshal(os)
  os:marshalInt32(self.targetId)
end
function CGetAwardReq:unmarshal(os)
  self.targetId = os:unmarshalInt32()
end
function CGetAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetAwardReq
