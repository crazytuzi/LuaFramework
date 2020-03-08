local CGetAwardbeforeSignReq = class("CGetAwardbeforeSignReq")
CGetAwardbeforeSignReq.TYPEID = 12593424
function CGetAwardbeforeSignReq:ctor(day)
  self.id = 12593424
  self.day = day or nil
end
function CGetAwardbeforeSignReq:marshal(os)
  os:marshalInt32(self.day)
end
function CGetAwardbeforeSignReq:unmarshal(os)
  self.day = os:unmarshalInt32()
end
function CGetAwardbeforeSignReq:sizepolicy(size)
  return size <= 65535
end
return CGetAwardbeforeSignReq
