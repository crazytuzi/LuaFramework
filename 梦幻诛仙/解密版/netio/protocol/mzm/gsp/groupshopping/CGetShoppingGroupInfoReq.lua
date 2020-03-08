local CGetShoppingGroupInfoReq = class("CGetShoppingGroupInfoReq")
CGetShoppingGroupInfoReq.TYPEID = 12623638
function CGetShoppingGroupInfoReq:ctor(group_id)
  self.id = 12623638
  self.group_id = group_id or nil
end
function CGetShoppingGroupInfoReq:marshal(os)
  os:marshalInt64(self.group_id)
end
function CGetShoppingGroupInfoReq:unmarshal(os)
  self.group_id = os:unmarshalInt64()
end
function CGetShoppingGroupInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetShoppingGroupInfoReq
