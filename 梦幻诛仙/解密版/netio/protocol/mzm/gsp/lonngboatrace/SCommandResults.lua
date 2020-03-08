local SCommandResults = class("SCommandResults")
SCommandResults.TYPEID = 12619270
SCommandResults.CORRECT = 0
SCommandResults.WRONG = 1
SCommandResults.RANDOM = 2
SCommandResults.NON_RANDOM = 3
SCommandResults.CALC_SPEED = 4
SCommandResults.NON_CALC_SPEED = 5
function SCommandResults:ctor(phaseId, teamId2isAllRight, roleId2isRight, isRandom, endTimeStamp, currTimeStamp, calcSpeed)
  self.id = 12619270
  self.phaseId = phaseId or nil
  self.teamId2isAllRight = teamId2isAllRight or {}
  self.roleId2isRight = roleId2isRight or {}
  self.isRandom = isRandom or nil
  self.endTimeStamp = endTimeStamp or nil
  self.currTimeStamp = currTimeStamp or nil
  self.calcSpeed = calcSpeed or nil
end
function SCommandResults:marshal(os)
  os:marshalInt32(self.phaseId)
  do
    local _size_ = 0
    for _, _ in pairs(self.teamId2isAllRight) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.teamId2isAllRight) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.roleId2isRight) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.roleId2isRight) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.isRandom)
  os:marshalInt64(self.endTimeStamp)
  os:marshalInt64(self.currTimeStamp)
  os:marshalInt32(self.calcSpeed)
end
function SCommandResults:unmarshal(os)
  self.phaseId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.teamId2isAllRight[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.roleId2isRight[k] = v
  end
  self.isRandom = os:unmarshalInt32()
  self.endTimeStamp = os:unmarshalInt64()
  self.currTimeStamp = os:unmarshalInt64()
  self.calcSpeed = os:unmarshalInt32()
end
function SCommandResults:sizepolicy(size)
  return size <= 65535
end
return SCommandResults
