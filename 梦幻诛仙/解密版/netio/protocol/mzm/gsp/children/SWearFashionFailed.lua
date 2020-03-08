local SWearFashionFailed = class("SWearFashionFailed")
SWearFashionFailed.TYPEID = 12609353
SWearFashionFailed.ERROR_EXPIRED = -1
function SWearFashionFailed:ctor(childid, fashion_cfgid, retcode)
  self.id = 12609353
  self.childid = childid or nil
  self.fashion_cfgid = fashion_cfgid or nil
  self.retcode = retcode or nil
end
function SWearFashionFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.fashion_cfgid)
  os:marshalInt32(self.retcode)
end
function SWearFashionFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.fashion_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SWearFashionFailed:sizepolicy(size)
  return size <= 65535
end
return SWearFashionFailed
