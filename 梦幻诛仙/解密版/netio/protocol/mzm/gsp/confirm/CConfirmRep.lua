local CConfirmRep = class("CConfirmRep")
CConfirmRep.TYPEID = 12617987
CConfirmRep.REPLY_ACCEPT = 1
CConfirmRep.REPLY_REFUSE = 2
function CConfirmRep:ctor(confirmType, sessionid, reply)
  self.id = 12617987
  self.confirmType = confirmType or nil
  self.sessionid = sessionid or nil
  self.reply = reply or nil
end
function CConfirmRep:marshal(os)
  os:marshalInt32(self.confirmType)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.reply)
end
function CConfirmRep:unmarshal(os)
  self.confirmType = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CConfirmRep:sizepolicy(size)
  return size <= 65535
end
return CConfirmRep
