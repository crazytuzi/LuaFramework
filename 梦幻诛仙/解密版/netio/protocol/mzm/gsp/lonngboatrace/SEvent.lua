local SEvent = class("SEvent")
SEvent.TYPEID = 12619271
SEvent.CALC_SPEED = 0
SEvent.NON_CALC_SPEED = 1
function SEvent:ctor(phaseId, eventTriggerId, team2eventId, endTimeStamp, currTimeStamp, calcSpeed)
  self.id = 12619271
  self.phaseId = phaseId or nil
  self.eventTriggerId = eventTriggerId or nil
  self.team2eventId = team2eventId or {}
  self.endTimeStamp = endTimeStamp or nil
  self.currTimeStamp = currTimeStamp or nil
  self.calcSpeed = calcSpeed or nil
end
function SEvent:marshal(os)
  os:marshalInt32(self.phaseId)
  os:marshalInt32(self.eventTriggerId)
  do
    local _size_ = 0
    for _, _ in pairs(self.team2eventId) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.team2eventId) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt64(self.endTimeStamp)
  os:marshalInt64(self.currTimeStamp)
  os:marshalInt32(self.calcSpeed)
end
function SEvent:unmarshal(os)
  self.phaseId = os:unmarshalInt32()
  self.eventTriggerId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.team2eventId[k] = v
  end
  self.endTimeStamp = os:unmarshalInt64()
  self.currTimeStamp = os:unmarshalInt64()
  self.calcSpeed = os:unmarshalInt32()
end
function SEvent:sizepolicy(size)
  return size <= 65535
end
return SEvent
