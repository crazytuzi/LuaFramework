local SBeginConfirmSwornName = class("SBeginConfirmSwornName")
SBeginConfirmSwornName.TYPEID = 12597772
function SBeginConfirmSwornName:ctor(swornid, roleid, name1, name2)
  self.id = 12597772
  self.swornid = swornid or nil
  self.roleid = roleid or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
end
function SBeginConfirmSwornName:marshal(os)
  os:marshalInt64(self.swornid)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
end
function SBeginConfirmSwornName:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
end
function SBeginConfirmSwornName:sizepolicy(size)
  return size <= 65535
end
return SBeginConfirmSwornName
