local SPetFightCVCStart = class("SPetFightCVCStart")
SPetFightCVCStart.TYPEID = 12594225
function SPetFightCVCStart:ctor(recordid)
  self.id = 12594225
  self.recordid = recordid or nil
end
function SPetFightCVCStart:marshal(os)
  os:marshalInt64(self.recordid)
end
function SPetFightCVCStart:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function SPetFightCVCStart:sizepolicy(size)
  return size <= 65535
end
return SPetFightCVCStart
