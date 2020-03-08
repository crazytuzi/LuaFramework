local SUnMountJewelSuccess = class("SUnMountJewelSuccess")
SUnMountJewelSuccess.TYPEID = 12618769
function SUnMountJewelSuccess:ctor(bagId, grid, index)
  self.id = 12618769
  self.bagId = bagId or nil
  self.grid = grid or nil
  self.index = index or nil
end
function SUnMountJewelSuccess:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.index)
end
function SUnMountJewelSuccess:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SUnMountJewelSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnMountJewelSuccess
