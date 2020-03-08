local SNextFestivalInfoRes = class("SNextFestivalInfoRes")
SNextFestivalInfoRes.TYPEID = 12600068
function SNextFestivalInfoRes:ctor(festivalAwardid)
  self.id = 12600068
  self.festivalAwardid = festivalAwardid or nil
end
function SNextFestivalInfoRes:marshal(os)
  os:marshalInt32(self.festivalAwardid)
end
function SNextFestivalInfoRes:unmarshal(os)
  self.festivalAwardid = os:unmarshalInt32()
end
function SNextFestivalInfoRes:sizepolicy(size)
  return size <= 65535
end
return SNextFestivalInfoRes
