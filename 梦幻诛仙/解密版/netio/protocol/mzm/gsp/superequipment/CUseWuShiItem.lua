local CUseWuShiItem = class("CUseWuShiItem")
CUseWuShiItem.TYPEID = 12618774
function CUseWuShiItem:ctor(bagId, grid)
  self.id = 12618774
  self.bagId = bagId or nil
  self.grid = grid or nil
end
function CUseWuShiItem:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
end
function CUseWuShiItem:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
end
function CUseWuShiItem:sizepolicy(size)
  return size <= 65535
end
return CUseWuShiItem
