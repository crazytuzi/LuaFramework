local CGetPointRaceRank = class("CGetPointRaceRank")
CGetPointRaceRank.TYPEID = 12617021
function CGetPointRaceRank:ctor(rank_type, from, to)
  self.id = 12617021
  self.rank_type = rank_type or nil
  self.from = from or nil
  self.to = to or nil
end
function CGetPointRaceRank:marshal(os)
  os:marshalUInt8(self.rank_type)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
end
function CGetPointRaceRank:unmarshal(os)
  self.rank_type = os:unmarshalUInt8()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
end
function CGetPointRaceRank:sizepolicy(size)
  return size <= 65535
end
return CGetPointRaceRank
