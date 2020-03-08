local SConfirmBro = class("SConfirmBro")
SConfirmBro.TYPEID = 12617985
function SConfirmBro:ctor(confirmType, memberId, reply)
  self.id = 12617985
  self.confirmType = confirmType or nil
  self.memberId = memberId or nil
  self.reply = reply or nil
end
function SConfirmBro:marshal(os)
  os:marshalInt32(self.confirmType)
  os:marshalInt64(self.memberId)
  os:marshalInt32(self.reply)
end
function SConfirmBro:unmarshal(os)
  self.confirmType = os:unmarshalInt32()
  self.memberId = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function SConfirmBro:sizepolicy(size)
  return size <= 65535
end
return SConfirmBro
