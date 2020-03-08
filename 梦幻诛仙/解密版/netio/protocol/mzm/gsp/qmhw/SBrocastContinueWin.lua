local SBrocastContinueWin = class("SBrocastContinueWin")
SBrocastContinueWin.TYPEID = 12601872
function SBrocastContinueWin:ctor(roleid, rolename, count)
  self.id = 12601872
  self.roleid = roleid or nil
  self.rolename = rolename or nil
  self.count = count or nil
end
function SBrocastContinueWin:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
  os:marshalInt32(self.count)
end
function SBrocastContinueWin:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
  self.count = os:unmarshalInt32()
end
function SBrocastContinueWin:sizepolicy(size)
  return size <= 65535
end
return SBrocastContinueWin
