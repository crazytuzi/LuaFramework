local OctetsStream = require("netio.OctetsStream")
local PropSys = class("PropSys")
function PropSys:ctor(potential_point, propMap, basePropMap, isAutoAssign, autoAssignMap, isCanRefreshProp)
  self.potential_point = potential_point or nil
  self.propMap = propMap or {}
  self.basePropMap = basePropMap or {}
  self.isAutoAssign = isAutoAssign or nil
  self.autoAssignMap = autoAssignMap or {}
  self.isCanRefreshProp = isCanRefreshProp or nil
end
function PropSys:marshal(os)
  os:marshalInt32(self.potential_point)
  do
    local _size_ = 0
    for _, _ in pairs(self.propMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.propMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.basePropMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.basePropMap) do
      os:marshalInt32(k)
      os:marshalFloat(v)
    end
  end
  os:marshalInt32(self.isAutoAssign)
  do
    local _size_ = 0
    for _, _ in pairs(self.autoAssignMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.autoAssignMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.isCanRefreshProp)
end
function PropSys:unmarshal(os)
  self.potential_point = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.propMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalFloat()
    self.basePropMap[k] = v
  end
  self.isAutoAssign = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.autoAssignMap[k] = v
  end
  self.isCanRefreshProp = os:unmarshalInt32()
end
return PropSys
