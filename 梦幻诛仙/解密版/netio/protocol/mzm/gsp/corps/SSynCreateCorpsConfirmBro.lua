local SSynCreateCorpsConfirmBro = class("SSynCreateCorpsConfirmBro")
SSynCreateCorpsConfirmBro.TYPEID = 12617507
function SSynCreateCorpsConfirmBro:ctor(memberId, reply)
  self.id = 12617507
  self.memberId = memberId or nil
  self.reply = reply or nil
end
function SSynCreateCorpsConfirmBro:marshal(os)
  os:marshalInt64(self.memberId)
  os:marshalInt32(self.reply)
end
function SSynCreateCorpsConfirmBro:unmarshal(os)
  self.memberId = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function SSynCreateCorpsConfirmBro:sizepolicy(size)
  return size <= 65535
end
return SSynCreateCorpsConfirmBro
