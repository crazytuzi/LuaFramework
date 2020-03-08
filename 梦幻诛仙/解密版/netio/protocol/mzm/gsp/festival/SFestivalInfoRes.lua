local SFestivalInfoRes = class("SFestivalInfoRes")
SFestivalInfoRes.TYPEID = 12600067
SFestivalInfoRes.NOT_TAKE = 0
SFestivalInfoRes.TAKED = 1
function SFestivalInfoRes:ctor(festivalAwardid, awardState)
  self.id = 12600067
  self.festivalAwardid = festivalAwardid or nil
  self.awardState = awardState or nil
end
function SFestivalInfoRes:marshal(os)
  os:marshalInt32(self.festivalAwardid)
  os:marshalInt32(self.awardState)
end
function SFestivalInfoRes:unmarshal(os)
  self.festivalAwardid = os:unmarshalInt32()
  self.awardState = os:unmarshalInt32()
end
function SFestivalInfoRes:sizepolicy(size)
  return size <= 65535
end
return SFestivalInfoRes
