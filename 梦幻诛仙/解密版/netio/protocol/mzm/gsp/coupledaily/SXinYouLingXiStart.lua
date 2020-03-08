local SXinYouLingXiStart = class("SXinYouLingXiStart")
SXinYouLingXiStart.TYPEID = 12602371
function SXinYouLingXiStart:ctor(sessionId)
  self.id = 12602371
  self.sessionId = sessionId or nil
end
function SXinYouLingXiStart:marshal(os)
  os:marshalInt64(self.sessionId)
end
function SXinYouLingXiStart:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
end
function SXinYouLingXiStart:sizepolicy(size)
  return size <= 65535
end
return SXinYouLingXiStart
