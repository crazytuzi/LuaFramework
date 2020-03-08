local STakeFestivalAwardRes = class("STakeFestivalAwardRes")
STakeFestivalAwardRes.TYPEID = 12600069
function STakeFestivalAwardRes:ctor(festivalAwardid)
  self.id = 12600069
  self.festivalAwardid = festivalAwardid or nil
end
function STakeFestivalAwardRes:marshal(os)
  os:marshalInt32(self.festivalAwardid)
end
function STakeFestivalAwardRes:unmarshal(os)
  self.festivalAwardid = os:unmarshalInt32()
end
function STakeFestivalAwardRes:sizepolicy(size)
  return size <= 65535
end
return STakeFestivalAwardRes
