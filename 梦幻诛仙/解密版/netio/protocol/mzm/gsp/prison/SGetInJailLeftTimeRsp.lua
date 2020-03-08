local SGetInJailLeftTimeRsp = class("SGetInJailLeftTimeRsp")
SGetInJailLeftTimeRsp.TYPEID = 12620046
function SGetInJailLeftTimeRsp:ctor(endTimeStamp)
  self.id = 12620046
  self.endTimeStamp = endTimeStamp or nil
end
function SGetInJailLeftTimeRsp:marshal(os)
  os:marshalInt64(self.endTimeStamp)
end
function SGetInJailLeftTimeRsp:unmarshal(os)
  self.endTimeStamp = os:unmarshalInt64()
end
function SGetInJailLeftTimeRsp:sizepolicy(size)
  return size <= 65535
end
return SGetInJailLeftTimeRsp
