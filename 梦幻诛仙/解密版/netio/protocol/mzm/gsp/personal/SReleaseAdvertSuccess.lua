local SReleaseAdvertSuccess = class("SReleaseAdvertSuccess")
SReleaseAdvertSuccess.TYPEID = 12603663
function SReleaseAdvertSuccess:ctor(advertType)
  self.id = 12603663
  self.advertType = advertType or nil
end
function SReleaseAdvertSuccess:marshal(os)
  os:marshalInt32(self.advertType)
end
function SReleaseAdvertSuccess:unmarshal(os)
  self.advertType = os:unmarshalInt32()
end
function SReleaseAdvertSuccess:sizepolicy(size)
  return size <= 65535
end
return SReleaseAdvertSuccess
