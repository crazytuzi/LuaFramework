local OctetsStream = require("netio.OctetsStream")
local RoleFloorActivityInfo = class("RoleFloorActivityInfo")
function RoleFloorActivityInfo:ctor(finishFloor, historyFinishFloors)
  self.finishFloor = finishFloor or {}
  self.historyFinishFloors = historyFinishFloors or {}
end
function RoleFloorActivityInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.finishFloor))
  for _, v in ipairs(self.finishFloor) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.historyFinishFloors))
  for _, v in ipairs(self.historyFinishFloors) do
    os:marshalInt32(v)
  end
end
function RoleFloorActivityInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.floor.RoleFloorInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.finishFloor, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.historyFinishFloors, v)
  end
end
return RoleFloorActivityInfo
