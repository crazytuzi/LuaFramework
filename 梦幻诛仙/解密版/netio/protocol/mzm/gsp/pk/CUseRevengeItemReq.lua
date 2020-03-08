local CUseRevengeItemReq = class("CUseRevengeItemReq")
CUseRevengeItemReq.TYPEID = 12619791
function CUseRevengeItemReq:ctor(bag_id, grid)
  self.id = 12619791
  self.bag_id = bag_id or nil
  self.grid = grid or nil
end
function CUseRevengeItemReq:marshal(os)
  os:marshalInt32(self.bag_id)
  os:marshalInt32(self.grid)
end
function CUseRevengeItemReq:unmarshal(os)
  self.bag_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
end
function CUseRevengeItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseRevengeItemReq
