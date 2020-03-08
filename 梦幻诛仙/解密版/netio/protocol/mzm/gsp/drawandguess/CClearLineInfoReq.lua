local CClearLineInfoReq = class("CClearLineInfoReq")
CClearLineInfoReq.TYPEID = 12617253
function CClearLineInfoReq:ctor(sessionId)
  self.id = 12617253
  self.sessionId = sessionId or nil
end
function CClearLineInfoReq:marshal(os)
  os:marshalInt64(self.sessionId)
end
function CClearLineInfoReq:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
end
function CClearLineInfoReq:sizepolicy(size)
  return size <= 65535
end
return CClearLineInfoReq
