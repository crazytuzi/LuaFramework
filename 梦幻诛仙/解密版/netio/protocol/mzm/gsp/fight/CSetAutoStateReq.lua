local CSetAutoStateReq = class("CSetAutoStateReq")
CSetAutoStateReq.TYPEID = 12594187
function CSetAutoStateReq:ctor(auto_state)
  self.id = 12594187
  self.auto_state = auto_state or nil
end
function CSetAutoStateReq:marshal(os)
  os:marshalInt32(self.auto_state)
end
function CSetAutoStateReq:unmarshal(os)
  self.auto_state = os:unmarshalInt32()
end
function CSetAutoStateReq:sizepolicy(size)
  return size <= 65535
end
return CSetAutoStateReq
