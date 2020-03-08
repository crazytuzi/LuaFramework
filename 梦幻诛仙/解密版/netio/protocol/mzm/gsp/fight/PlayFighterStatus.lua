local OctetsStream = require("netio.OctetsStream")
local PlayFighterStatus = class("PlayFighterStatus")
function PlayFighterStatus:ctor(fightermap)
  self.fightermap = fightermap or {}
end
function PlayFighterStatus:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.fightermap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.fightermap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function PlayFighterStatus:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatuses")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fightermap[k] = v
  end
end
return PlayFighterStatus
