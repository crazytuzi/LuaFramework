local CSendCommand = class("CSendCommand")
CSendCommand.TYPEID = 12619276
function CSendCommand:ctor(raceId, phaseNo, round, times, commandList)
  self.id = 12619276
  self.raceId = raceId or nil
  self.phaseNo = phaseNo or nil
  self.round = round or nil
  self.times = times or nil
  self.commandList = commandList or {}
end
function CSendCommand:marshal(os)
  os:marshalInt32(self.raceId)
  os:marshalInt32(self.phaseNo)
  os:marshalInt32(self.round)
  os:marshalInt32(self.times)
  os:marshalCompactUInt32(table.getn(self.commandList))
  for _, v in ipairs(self.commandList) do
    os:marshalInt32(v)
  end
end
function CSendCommand:unmarshal(os)
  self.raceId = os:unmarshalInt32()
  self.phaseNo = os:unmarshalInt32()
  self.round = os:unmarshalInt32()
  self.times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.commandList, v)
  end
end
function CSendCommand:sizepolicy(size)
  return size <= 65535
end
return CSendCommand
