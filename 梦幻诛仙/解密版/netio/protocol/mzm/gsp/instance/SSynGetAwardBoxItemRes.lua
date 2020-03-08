local SSynGetAwardBoxItemRes = class("SSynGetAwardBoxItemRes")
SSynGetAwardBoxItemRes.TYPEID = 12591364
function SSynGetAwardBoxItemRes:ctor(awardUuid, itemid, roleid)
  self.id = 12591364
  self.awardUuid = awardUuid or nil
  self.itemid = itemid or nil
  self.roleid = roleid or nil
end
function SSynGetAwardBoxItemRes:marshal(os)
  os:marshalInt64(self.awardUuid)
  os:marshalInt32(self.itemid)
  os:marshalInt64(self.roleid)
end
function SSynGetAwardBoxItemRes:unmarshal(os)
  self.awardUuid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
end
function SSynGetAwardBoxItemRes:sizepolicy(size)
  return size <= 65535
end
return SSynGetAwardBoxItemRes
