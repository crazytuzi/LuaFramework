local OctetsStream = require("netio.OctetsStream")
local EquipFumoInfo = class("EquipFumoInfo")
function EquipFumoInfo:ctor(bagid, itemid, uuid, expirationtime, propertyType, addValue)
  self.bagid = bagid or nil
  self.itemid = itemid or nil
  self.uuid = uuid or nil
  self.expirationtime = expirationtime or nil
  self.propertyType = propertyType or nil
  self.addValue = addValue or nil
end
function EquipFumoInfo:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemid)
  os:marshalInt64(self.uuid)
  os:marshalInt64(self.expirationtime)
  os:marshalInt32(self.propertyType)
  os:marshalInt32(self.addValue)
end
function EquipFumoInfo:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.expirationtime = os:unmarshalInt64()
  self.propertyType = os:unmarshalInt32()
  self.addValue = os:unmarshalInt32()
end
return EquipFumoInfo
