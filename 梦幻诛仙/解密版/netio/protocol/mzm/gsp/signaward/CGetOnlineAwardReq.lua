local CGetOnlineAwardReq = class("CGetOnlineAwardReq")
CGetOnlineAwardReq.TYPEID = 12593418
function CGetOnlineAwardReq:ctor(time)
  self.id = 12593418
  self.time = time or nil
end
function CGetOnlineAwardReq:marshal(os)
  os:marshalInt32(self.time)
end
function CGetOnlineAwardReq:unmarshal(os)
  self.time = os:unmarshalInt32()
end
function CGetOnlineAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetOnlineAwardReq
