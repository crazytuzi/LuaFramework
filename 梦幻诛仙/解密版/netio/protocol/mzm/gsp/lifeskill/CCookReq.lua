local CCookReq = class("CCookReq")
CCookReq.TYPEID = 12589060
function CCookReq:ctor(skillBagId)
  self.id = 12589060
  self.skillBagId = skillBagId or nil
end
function CCookReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CCookReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CCookReq:sizepolicy(size)
  return size <= 65535
end
return CCookReq
