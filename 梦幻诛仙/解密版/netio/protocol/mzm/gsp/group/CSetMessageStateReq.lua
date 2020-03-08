local CSetMessageStateReq = class("CSetMessageStateReq")
CSetMessageStateReq.TYPEID = 12605212
function CSetMessageStateReq:ctor(groupid, message_state)
  self.id = 12605212
  self.groupid = groupid or nil
  self.message_state = message_state or nil
end
function CSetMessageStateReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalUInt8(self.message_state)
end
function CSetMessageStateReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.message_state = os:unmarshalUInt8()
end
function CSetMessageStateReq:sizepolicy(size)
  return size <= 65535
end
return CSetMessageStateReq
