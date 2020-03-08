local CJoinShoppingGroupReq = class("CJoinShoppingGroupReq")
CJoinShoppingGroupReq.TYPEID = 12623619
function CJoinShoppingGroupReq:ctor(group_id, current_yuanbao)
  self.id = 12623619
  self.group_id = group_id or nil
  self.current_yuanbao = current_yuanbao or nil
end
function CJoinShoppingGroupReq:marshal(os)
  os:marshalInt64(self.group_id)
  os:marshalInt64(self.current_yuanbao)
end
function CJoinShoppingGroupReq:unmarshal(os)
  self.group_id = os:unmarshalInt64()
  self.current_yuanbao = os:unmarshalInt64()
end
function CJoinShoppingGroupReq:sizepolicy(size)
  return size <= 65535
end
return CJoinShoppingGroupReq
