local CMountJewel = class("CMountJewel")
CMountJewel.TYPEID = 12618770
function CMountJewel:ctor(bagId, grid, index, jewelCfgId)
  self.id = 12618770
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.index = index or nil
  self.jewelCfgId = jewelCfgId or nil
end
function CMountJewel:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.index)
  os:marshalInt32(self.jewelCfgId)
end
function CMountJewel:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.jewelCfgId = os:unmarshalInt32()
end
function CMountJewel:sizepolicy(size)
  return size <= 65535
end
return CMountJewel
