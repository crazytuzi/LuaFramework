local CAppointLeaderReq = class("CAppointLeaderReq")
CAppointLeaderReq.TYPEID = 12588317
function CAppointLeaderReq:ctor(new_leader)
  self.id = 12588317
  self.new_leader = new_leader or nil
end
function CAppointLeaderReq:marshal(os)
  os:marshalInt64(self.new_leader)
end
function CAppointLeaderReq:unmarshal(os)
  self.new_leader = os:unmarshalInt64()
end
function CAppointLeaderReq:sizepolicy(size)
  return size <= 65535
end
return CAppointLeaderReq
