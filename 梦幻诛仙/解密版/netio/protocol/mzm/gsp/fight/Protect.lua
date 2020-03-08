local OctetsStream = require("netio.OctetsStream")
local Protect = class("Protect")
function Protect:ctor(protecterids, protecterStatuses, influenceMap)
  self.protecterids = protecterids or {}
  self.protecterStatuses = protecterStatuses or {}
  self.influenceMap = influenceMap or {}
end
function Protect:marshal(os)
  os:marshalCompactUInt32(table.getn(self.protecterids))
  for _, v in ipairs(self.protecterids) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.protecterStatuses))
  for _, v in ipairs(self.protecterStatuses) do
    v:marshal(os)
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
function Protect:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.protecterids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.protecterStatuses, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.InfluenceOther")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.influenceMap[k] = v
  end
end
return Protect
