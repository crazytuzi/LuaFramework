local SEntry = class("SEntry")
SEntry.TYPEID = 12619265
function SEntry:ctor(raceId, matchBeginTimeStamp)
  self.id = 12619265
  self.raceId = raceId or nil
  self.matchBeginTimeStamp = matchBeginTimeStamp or nil
end
function SEntry:marshal(os)
  os:marshalInt32(self.raceId)
  os:marshalInt64(self.matchBeginTimeStamp)
end
function SEntry:unmarshal(os)
  self.raceId = os:unmarshalInt32()
  self.matchBeginTimeStamp = os:unmarshalInt64()
end
function SEntry:sizepolicy(size)
  return size <= 65535
end
return SEntry
