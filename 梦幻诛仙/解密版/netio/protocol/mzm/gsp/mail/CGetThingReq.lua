local CGetThingReq = class("CGetThingReq")
CGetThingReq.TYPEID = 12592905
function CGetThingReq:ctor(mailIndex)
  self.id = 12592905
  self.mailIndex = mailIndex or nil
end
function CGetThingReq:marshal(os)
  os:marshalInt32(self.mailIndex)
end
function CGetThingReq:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
end
function CGetThingReq:sizepolicy(size)
  return size <= 65535
end
return CGetThingReq
