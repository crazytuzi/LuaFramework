local CCheckXItemInfoReq = class("CCheckXItemInfoReq")
CCheckXItemInfoReq.TYPEID = 12584451
function CCheckXItemInfoReq:ctor(roleIdChecked, itemIndex)
  self.id = 12584451
  self.roleIdChecked = roleIdChecked or nil
  self.itemIndex = itemIndex or nil
end
function CCheckXItemInfoReq:marshal(os)
  os:marshalInt64(self.roleIdChecked)
  os:marshalInt32(self.itemIndex)
end
function CCheckXItemInfoReq:unmarshal(os)
  self.roleIdChecked = os:unmarshalInt64()
  self.itemIndex = os:unmarshalInt32()
end
function CCheckXItemInfoReq:sizepolicy(size)
  return size <= 65535
end
return CCheckXItemInfoReq
