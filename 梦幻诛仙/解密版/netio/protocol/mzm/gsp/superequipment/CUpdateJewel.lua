local CUpdateJewel = class("CUpdateJewel")
CUpdateJewel.TYPEID = 12618766
function CUpdateJewel:ctor(bagId, grid, index)
  self.id = 12618766
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.index = index or nil
end
function CUpdateJewel:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.index)
end
function CUpdateJewel:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CUpdateJewel:sizepolicy(size)
  return size <= 65535
end
return CUpdateJewel
