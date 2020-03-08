local SGetIndianaAwardInfoFail = class("SGetIndianaAwardInfoFail")
SGetIndianaAwardInfoFail.TYPEID = 12629000
function SGetIndianaAwardInfoFail:ctor(res)
  self.id = 12629000
  self.res = res or nil
end
function SGetIndianaAwardInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetIndianaAwardInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetIndianaAwardInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetIndianaAwardInfoFail
