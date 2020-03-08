local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
local SCakeInfoChangeBro = class("SCakeInfoChangeBro")
SCakeInfoChangeBro.TYPEID = 12627716
SCakeInfoChangeBro.REASON_ADD = 1
SCakeInfoChangeBro.REASON_MAKE = 2
function SCakeInfoChangeBro:ctor(activityId, roleId, masterName, makeRoleId, itemId, reason, cakeInfo)
  self.id = 12627716
  self.activityId = activityId or nil
  self.roleId = roleId or nil
  self.masterName = masterName or nil
  self.makeRoleId = makeRoleId or nil
  self.itemId = itemId or nil
  self.reason = reason or nil
  self.cakeInfo = cakeInfo or CakeDetailInfo.new()
end
function SCakeInfoChangeBro:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.masterName)
  os:marshalInt64(self.makeRoleId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.reason)
  self.cakeInfo:marshal(os)
end
function SCakeInfoChangeBro:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.masterName = os:unmarshalOctets()
  self.makeRoleId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.reason = os:unmarshalInt32()
  self.cakeInfo = CakeDetailInfo.new()
  self.cakeInfo:unmarshal(os)
end
function SCakeInfoChangeBro:sizepolicy(size)
  return size <= 65535
end
return SCakeInfoChangeBro
