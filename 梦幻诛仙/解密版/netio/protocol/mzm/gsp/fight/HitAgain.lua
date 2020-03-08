local OctetsStream = require("netio.OctetsStream")
local HitAgain = class("HitAgain")
function HitAgain:ctor(targets, status_map, influenceMap)
  self.targets = targets or {}
  self.status_map = status_map or {}
  self.influenceMap = influenceMap or {}
end
function HitAgain:marshal(os)
  os:marshalCompactUInt32(table.getn(self.targets))
  for _, v in ipairs(self.targets) do
    os:marshalInt32(v)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.status_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.status_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.influenceMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.influenceMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function HitAgain:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.targets, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.AttackResult")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.status_map[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.InfluenceOther")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.influenceMap[k] = v
  end
end
return HitAgain
