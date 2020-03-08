local SGetOrRefuseItemRes = class("SGetOrRefuseItemRes")
SGetOrRefuseItemRes.TYPEID = 12591365
function SGetOrRefuseItemRes:ctor(awardUuid, itemid, roleid, code)
  self.id = 12591365
  self.awardUuid = awardUuid or nil
  self.itemid = itemid or nil
  self.roleid = roleid or nil
  self.code = code or nil
end
function SGetOrRefuseItemRes:marshal(os)
  os:marshalInt64(self.awardUuid)
  os:marshalInt32(self.itemid)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.code)
end
function SGetOrRefuseItemRes:unmarshal(os)
  self.awardUuid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.code = os:unmarshalInt32()
end
function SGetOrRefuseItemRes:sizepolicy(size)
  return size <= 65535
end
return SGetOrRefuseItemRes
