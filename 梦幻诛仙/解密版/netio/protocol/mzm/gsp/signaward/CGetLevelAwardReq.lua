local CGetLevelAwardReq = class("CGetLevelAwardReq")
CGetLevelAwardReq.TYPEID = 12593412
function CGetLevelAwardReq:ctor(level)
  self.id = 12593412
  self.level = level or nil
end
function CGetLevelAwardReq:marshal(os)
  os:marshalInt32(self.level)
end
function CGetLevelAwardReq:unmarshal(os)
  self.level = os:unmarshalInt32()
end
function CGetLevelAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetLevelAwardReq
