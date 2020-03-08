local OctetsStream = require("netio.OctetsStream")
local PlaySummon = class("PlaySummon")
PlaySummon.SUMMON_BACK = 0
PlaySummon.SUMMON = 1
PlaySummon.ACTIVE_TEAM = 2
PlaySummon.PASSIVE_TEAM = 3
function PlaySummon:ctor(result, fighterid, fighters, groupid, team)
  self.result = result or nil
  self.fighterid = fighterid or nil
  self.fighters = fighters or {}
  self.groupid = groupid or nil
  self.team = team or nil
end
function PlaySummon:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.fighterid)
  do
    local _size_ = 0
    for _, _ in pairs(self.fighters) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.fighters) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.groupid)
  os:marshalInt32(self.team)
end
function PlaySummon:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.fighterid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.Fighter")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fighters[k] = v
  end
  self.groupid = os:unmarshalInt32()
  self.team = os:unmarshalInt32()
end
return PlaySummon
