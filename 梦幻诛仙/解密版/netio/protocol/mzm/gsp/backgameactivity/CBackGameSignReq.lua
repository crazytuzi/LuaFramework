local CBackGameSignReq = class("CBackGameSignReq")
CBackGameSignReq.TYPEID = 12620556
function CBackGameSignReq:ctor(index)
  self.id = 12620556
  self.index = index or nil
end
function CBackGameSignReq:marshal(os)
  os:marshalInt32(self.index)
end
function CBackGameSignReq:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CBackGameSignReq:sizepolicy(size)
  return size <= 65535
end
return CBackGameSignReq
