local SDivorceRes = class("SDivorceRes")
SDivorceRes.TYPEID = 12599826
function SDivorceRes:ctor(sessionid)
  self.id = 12599826
  self.sessionid = sessionid or nil
end
function SDivorceRes:marshal(os)
  os:marshalInt64(self.sessionid)
end
function SDivorceRes:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
end
function SDivorceRes:sizepolicy(size)
  return size <= 65535
end
return SDivorceRes
