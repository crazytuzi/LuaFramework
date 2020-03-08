local CUseAxeItemReq = class("CUseAxeItemReq")
CUseAxeItemReq.TYPEID = 12584868
function CUseAxeItemReq:ctor(grid, num)
  self.id = 12584868
  self.grid = grid or nil
  self.num = num or nil
end
function CUseAxeItemReq:marshal(os)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.num)
end
function CUseAxeItemReq:unmarshal(os)
  self.grid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CUseAxeItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseAxeItemReq
