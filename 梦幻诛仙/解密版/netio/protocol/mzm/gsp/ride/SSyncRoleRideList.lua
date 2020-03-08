local SSyncRoleRideList = class("SSyncRoleRideList")
SSyncRoleRideList.TYPEID = 797957
function SSyncRoleRideList:ctor(mountRideCfgId, rideList)
  self.id = 797957
  self.mountRideCfgId = mountRideCfgId or nil
  self.rideList = rideList or {}
end
function SSyncRoleRideList:marshal(os)
  os:marshalInt32(self.mountRideCfgId)
  os:marshalCompactUInt32(table.getn(self.rideList))
  for _, v in ipairs(self.rideList) do
    v:marshal(os)
  end
end
function SSyncRoleRideList:unmarshal(os)
  self.mountRideCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ride.RideInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rideList, v)
  end
end
function SSyncRoleRideList:sizepolicy(size)
  return size <= 65535
end
return SSyncRoleRideList
