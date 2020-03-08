local CCancelQingYuanReq = class("CCancelQingYuanReq")
CCancelQingYuanReq.TYPEID = 12602890
function CCancelQingYuanReq:ctor(sessionid)
  self.id = 12602890
  self.sessionid = sessionid or nil
end
function CCancelQingYuanReq:marshal(os)
  os:marshalInt64(self.sessionid)
end
function CCancelQingYuanReq:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
end
function CCancelQingYuanReq:sizepolicy(size)
  return size <= 65535
end
return CCancelQingYuanReq
