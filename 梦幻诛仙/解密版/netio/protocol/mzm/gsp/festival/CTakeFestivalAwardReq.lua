local CTakeFestivalAwardReq = class("CTakeFestivalAwardReq")
CTakeFestivalAwardReq.TYPEID = 12600065
function CTakeFestivalAwardReq:ctor(festivalAwardid)
  self.id = 12600065
  self.festivalAwardid = festivalAwardid or nil
end
function CTakeFestivalAwardReq:marshal(os)
  os:marshalInt32(self.festivalAwardid)
end
function CTakeFestivalAwardReq:unmarshal(os)
  self.festivalAwardid = os:unmarshalInt32()
end
function CTakeFestivalAwardReq:sizepolicy(size)
  return size <= 65535
end
return CTakeFestivalAwardReq
