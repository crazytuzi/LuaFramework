local CUseBaoTuReq = class("CUseBaoTuReq")
CUseBaoTuReq.TYPEID = 12583684
function CUseBaoTuReq:ctor(uuid)
  self.id = 12583684
  self.uuid = uuid or nil
end
function CUseBaoTuReq:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseBaoTuReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseBaoTuReq:sizepolicy(size)
  return size <= 65535
end
return CUseBaoTuReq
