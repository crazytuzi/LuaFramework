local SSetMessageStateSuccess = class("SSetMessageStateSuccess")
SSetMessageStateSuccess.TYPEID = 12605198
function SSetMessageStateSuccess:ctor(groupid, message_state)
  self.id = 12605198
  self.groupid = groupid or nil
  self.message_state = message_state or nil
end
function SSetMessageStateSuccess:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalUInt8(self.message_state)
end
function SSetMessageStateSuccess:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.message_state = os:unmarshalUInt8()
end
function SSetMessageStateSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetMessageStateSuccess
