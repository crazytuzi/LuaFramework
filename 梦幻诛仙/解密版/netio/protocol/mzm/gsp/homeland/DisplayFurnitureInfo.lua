local OctetsStream = require("netio.OctetsStream")
local DisplayFurnitureInfo = class("DisplayFurnitureInfo")
function DisplayFurnitureInfo:ctor(x, y, direction, furnitureId)
  self.x = x or nil
  self.y = y or nil
  self.direction = direction or nil
  self.furnitureId = furnitureId or nil
end
function DisplayFurnitureInfo:marshal(os)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
  os:marshalInt32(self.direction)
  os:marshalInt32(self.furnitureId)
end
function DisplayFurnitureInfo:unmarshal(os)
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
  self.direction = os:unmarshalInt32()
  self.furnitureId = os:unmarshalInt32()
end
return DisplayFurnitureInfo
