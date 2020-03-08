local CUnMountJewel = class("CUnMountJewel")
CUnMountJewel.TYPEID = 12618763
function CUnMountJewel:ctor(bagId, grid, index)
  self.id = 12618763
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.index = index or nil
end
function CUnMountJewel:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.index)
end
function CUnMountJewel:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CUnMountJewel:sizepolicy(size)
  return size <= 65535
end
return CUnMountJewel
