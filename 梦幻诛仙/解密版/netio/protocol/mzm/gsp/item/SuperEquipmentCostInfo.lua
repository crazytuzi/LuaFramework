local OctetsStream = require("netio.OctetsStream")
local SuperEquipmentCostInfo = class("SuperEquipmentCostInfo")
function SuperEquipmentCostInfo:ctor(stage_cost_map, level_cost_map)
  self.stage_cost_map = stage_cost_map or {}
  self.level_cost_map = level_cost_map or {}
end
function SuperEquipmentCostInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.stage_cost_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.stage_cost_map) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.level_cost_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.level_cost_map) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SuperEquipmentCostInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.stage_cost_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.level_cost_map[k] = v
  end
end
return SuperEquipmentCostInfo
