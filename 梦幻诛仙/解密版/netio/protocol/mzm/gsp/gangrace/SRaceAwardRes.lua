local SRaceAwardRes = class("SRaceAwardRes")
SRaceAwardRes.TYPEID = 12602124
SRaceAwardRes.RACE_FAIL = 0
SRaceAwardRes.RACE_WIN = 1
function SRaceAwardRes:ctor(resultcode)
  self.id = 12602124
  self.resultcode = resultcode or nil
end
function SRaceAwardRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SRaceAwardRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SRaceAwardRes:sizepolicy(size)
  return size <= 65535
end
return SRaceAwardRes
