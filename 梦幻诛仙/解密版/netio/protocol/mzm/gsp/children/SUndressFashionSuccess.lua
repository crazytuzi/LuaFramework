local SUndressFashionSuccess = class("SUndressFashionSuccess")
SUndressFashionSuccess.TYPEID = 12609357
function SUndressFashionSuccess:ctor(childid, fashion_cfgid)
  self.id = 12609357
  self.childid = childid or nil
  self.fashion_cfgid = fashion_cfgid or nil
end
function SUndressFashionSuccess:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.fashion_cfgid)
end
function SUndressFashionSuccess:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.fashion_cfgid = os:unmarshalInt32()
end
function SUndressFashionSuccess:sizepolicy(size)
  return size <= 65535
end
return SUndressFashionSuccess
