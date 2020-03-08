local SUpdateJewelSuccess = class("SUpdateJewelSuccess")
SUpdateJewelSuccess.TYPEID = 12618768
function SUpdateJewelSuccess:ctor(bagId, grid, index, jewelCfgId)
  self.id = 12618768
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.index = index or nil
  self.jewelCfgId = jewelCfgId or nil
end
function SUpdateJewelSuccess:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.index)
  os:marshalInt32(self.jewelCfgId)
end
function SUpdateJewelSuccess:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.jewelCfgId = os:unmarshalInt32()
end
function SUpdateJewelSuccess:sizepolicy(size)
  return size <= 65535
end
return SUpdateJewelSuccess
