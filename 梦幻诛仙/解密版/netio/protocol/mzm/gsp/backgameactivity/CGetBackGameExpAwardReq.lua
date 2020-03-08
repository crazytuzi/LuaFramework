local CGetBackGameExpAwardReq = class("CGetBackGameExpAwardReq")
CGetBackGameExpAwardReq.TYPEID = 12620550
function CGetBackGameExpAwardReq:ctor(index)
  self.id = 12620550
  self.index = index or nil
end
function CGetBackGameExpAwardReq:marshal(os)
  os:marshalInt32(self.index)
end
function CGetBackGameExpAwardReq:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CGetBackGameExpAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetBackGameExpAwardReq
