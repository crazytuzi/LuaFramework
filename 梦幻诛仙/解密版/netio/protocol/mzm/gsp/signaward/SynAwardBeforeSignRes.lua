local SynAwardBeforeSignRes = class("SynAwardBeforeSignRes")
SynAwardBeforeSignRes.TYPEID = 12593423
function SynAwardBeforeSignRes:ctor(awardeddays, day)
  self.id = 12593423
  self.awardeddays = awardeddays or {}
  self.day = day or nil
end
function SynAwardBeforeSignRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardeddays))
  for _, v in ipairs(self.awardeddays) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.day)
end
function SynAwardBeforeSignRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.awardeddays, v)
  end
  self.day = os:unmarshalInt32()
end
function SynAwardBeforeSignRes:sizepolicy(size)
  return size <= 65535
end
return SynAwardBeforeSignRes
