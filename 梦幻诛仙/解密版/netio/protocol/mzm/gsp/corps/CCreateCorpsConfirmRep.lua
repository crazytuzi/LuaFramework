local CCreateCorpsConfirmRep = class("CCreateCorpsConfirmRep")
CCreateCorpsConfirmRep.TYPEID = 12617501
CCreateCorpsConfirmRep.REPLY_ACCEPT = 1
CCreateCorpsConfirmRep.REPLY_REFUSE = 2
function CCreateCorpsConfirmRep:ctor(sessionid, reply)
  self.id = 12617501
  self.sessionid = sessionid or nil
  self.reply = reply or nil
end
function CCreateCorpsConfirmRep:marshal(os)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.reply)
end
function CCreateCorpsConfirmRep:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CCreateCorpsConfirmRep:sizepolicy(size)
  return size <= 65535
end
return CCreateCorpsConfirmRep
