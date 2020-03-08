local SSyncRaceInfo = class("SSyncRaceInfo")
SSyncRaceInfo.TYPEID = 12619278
function SSyncRaceInfo:ctor(raceId, matchBeginTimeStamp, teamid2teamStat)
  self.id = 12619278
  self.raceId = raceId or nil
  self.matchBeginTimeStamp = matchBeginTimeStamp or nil
  self.teamid2teamStat = teamid2teamStat or {}
end
function SSyncRaceInfo:marshal(os)
  os:marshalInt32(self.raceId)
  os:marshalInt64(self.matchBeginTimeStamp)
  local _size_ = 0
  for _, _ in pairs(self.teamid2teamStat) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.teamid2teamStat) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function SSyncRaceInfo:unmarshal(os)
  self.raceId = os:unmarshalInt32()
  self.matchBeginTimeStamp = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.lonngboatrace.TeamStat")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.teamid2teamStat[k] = v
  end
end
function SSyncRaceInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRaceInfo
