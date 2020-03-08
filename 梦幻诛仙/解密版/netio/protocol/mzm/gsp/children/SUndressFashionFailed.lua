local SUndressFashionFailed = class("SUndressFashionFailed")
SUndressFashionFailed.TYPEID = 12609354
SUndressFashionFailed.ERROR_NONE_DRESSED = -1
function SUndressFashionFailed:ctor(childid, fashion_cfgid, retcode)
  self.id = 12609354
  self.childid = childid or nil
  self.fashion_cfgid = fashion_cfgid or nil
  self.retcode = retcode or nil
end
function SUndressFashionFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.fashion_cfgid)
  os:marshalInt32(self.retcode)
end
function SUndressFashionFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.fashion_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SUndressFashionFailed:sizepolicy(size)
  return size <= 65535
end
return SUndressFashionFailed
