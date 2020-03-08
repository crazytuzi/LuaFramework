local SRefuseWatchmoonRes = class("SRefuseWatchmoonRes")
SRefuseWatchmoonRes.TYPEID = 12600845
function SRefuseWatchmoonRes:ctor(roleid2, name2)
  self.id = 12600845
  self.roleid2 = roleid2 or nil
  self.name2 = name2 or nil
end
function SRefuseWatchmoonRes:marshal(os)
  os:marshalInt64(self.roleid2)
  os:marshalString(self.name2)
end
function SRefuseWatchmoonRes:unmarshal(os)
  self.roleid2 = os:unmarshalInt64()
  self.name2 = os:unmarshalString()
end
function SRefuseWatchmoonRes:sizepolicy(size)
  return size <= 65535
end
return SRefuseWatchmoonRes
