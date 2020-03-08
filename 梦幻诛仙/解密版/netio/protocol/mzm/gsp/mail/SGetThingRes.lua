local SGetThingRes = class("SGetThingRes")
SGetThingRes.TYPEID = 12592900
function SGetThingRes:ctor(mailIndex)
  self.id = 12592900
  self.mailIndex = mailIndex or nil
end
function SGetThingRes:marshal(os)
  os:marshalInt32(self.mailIndex)
end
function SGetThingRes:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
end
function SGetThingRes:sizepolicy(size)
  return size <= 65535
end
return SGetThingRes
