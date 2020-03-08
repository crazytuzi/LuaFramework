local SGetPointRaceRankFail = class("SGetPointRaceRankFail")
SGetPointRaceRankFail.TYPEID = 12617018
function SGetPointRaceRankFail:ctor(retcode, rank_type, from, to)
  self.id = 12617018
  self.retcode = retcode or nil
  self.rank_type = rank_type or nil
  self.from = from or nil
  self.to = to or nil
end
function SGetPointRaceRankFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalUInt8(self.rank_type)
  os:marshalInt32(self.from)
  os:marshalInt32(self.to)
end
function SGetPointRaceRankFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.rank_type = os:unmarshalUInt8()
  self.from = os:unmarshalInt32()
  self.to = os:unmarshalInt32()
end
function SGetPointRaceRankFail:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceRankFail
