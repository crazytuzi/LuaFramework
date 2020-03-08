local OctetsStream = require("netio.OctetsStream")
local FightTeam = class("FightTeam")
function FightTeam:ctor(groups, zhenFaid, zhenFaLevel)
  self.groups = groups or {}
  self.zhenFaid = zhenFaid or nil
  self.zhenFaLevel = zhenFaLevel or nil
end
function FightTeam:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.groups) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.groups) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.zhenFaid)
  os:marshalInt32(self.zhenFaLevel)
end
function FightTeam:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FightGroup")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.groups[k] = v
  end
  self.zhenFaid = os:unmarshalInt32()
  self.zhenFaLevel = os:unmarshalInt32()
end
return FightTeam
