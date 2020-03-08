local CHangStockingReq = class("CHangStockingReq")
CHangStockingReq.TYPEID = 12629512
function CHangStockingReq:ctor(target_role_id, position)
  self.id = 12629512
  self.target_role_id = target_role_id or nil
  self.position = position or nil
end
function CHangStockingReq:marshal(os)
  os:marshalInt64(self.target_role_id)
  os:marshalInt32(self.position)
end
function CHangStockingReq:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
  self.position = os:unmarshalInt32()
end
function CHangStockingReq:sizepolicy(size)
  return size <= 65535
end
return CHangStockingReq
