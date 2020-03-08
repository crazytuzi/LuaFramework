local OctetsStream = require("netio.OctetsStream")
local InfluenceOther = class("InfluenceOther")
function InfluenceOther:ctor(otherMap)
  self.otherMap = otherMap or {}
end
function InfluenceOther:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.otherMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.otherMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function InfluenceOther:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.otherMap[k] = v
  end
end
return InfluenceOther
