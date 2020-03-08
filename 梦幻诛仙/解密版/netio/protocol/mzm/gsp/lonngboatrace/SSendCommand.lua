local SSendCommand = class("SSendCommand")
SSendCommand.TYPEID = 12619277
function SSendCommand:ctor(phaseId, round, times, commandList, endTimeStamp, currTimeStamp)
  self.id = 12619277
  self.phaseId = phaseId or nil
  self.round = round or nil
  self.times = times or nil
  self.commandList = commandList or {}
  self.endTimeStamp = endTimeStamp or nil
  self.currTimeStamp = currTimeStamp or nil
end
function SSendCommand:marshal(os)
  os:marshalInt32(self.phaseId)
  os:marshalInt32(self.round)
  os:marshalInt32(self.times)
  os:marshalCompactUInt32(table.getn(self.commandList))
  for _, v in ipairs(self.commandList) do
    os:marshalInt32(v)
  end
  os:marshalInt64(self.endTimeStamp)
  os:marshalInt64(self.currTimeStamp)
end
function SSendCommand:unmarshal(os)
  self.phaseId = os:unmarshalInt32()
  self.round = os:unmarshalInt32()
  self.times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.commandList, v)
  end
  self.endTimeStamp = os:unmarshalInt64()
  self.currTimeStamp = os:unmarshalInt64()
end
function SSendCommand:sizepolicy(size)
  return size <= 65535
end
return SSendCommand
