local CCancelShouTuReq = class("CCancelShouTuReq")
CCancelShouTuReq.TYPEID = 12601609
function CCancelShouTuReq:ctor(sessionid)
  self.id = 12601609
  self.sessionid = sessionid or nil
end
function CCancelShouTuReq:marshal(os)
  os:marshalInt64(self.sessionid)
end
function CCancelShouTuReq:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
end
function CCancelShouTuReq:sizepolicy(size)
  return size <= 65535
end
return CCancelShouTuReq
