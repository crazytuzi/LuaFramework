local ForceLoginRep = class("ForceLoginRep")
ForceLoginRep.TYPEID = 105
function ForceLoginRep:ctor(userid, localsid, deny_flag, reserved)
  self.id = 105
  self.userid = userid or nil
  self.localsid = localsid or nil
  self.deny_flag = deny_flag or nil
  self.reserved = reserved or nil
end
function ForceLoginRep:marshal(os)
  os:marshalOctets(self.userid)
  os:marshalInt32(self.localsid)
  os:marshalInt32(self.deny_flag)
  os:marshalInt32(self.reserved)
end
function ForceLoginRep:unmarshal(os)
  self.userid = os:unmarshalOctets()
  self.localsid = os:unmarshalInt32()
  self.deny_flag = os:unmarshalInt32()
  self.reserved = os:unmarshalInt32()
end
function ForceLoginRep:sizepolicy(size)
  return size <= 65535
end
return ForceLoginRep
