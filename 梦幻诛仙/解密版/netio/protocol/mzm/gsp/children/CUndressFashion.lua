local CUndressFashion = class("CUndressFashion")
CUndressFashion.TYPEID = 12609356
function CUndressFashion:ctor(childid, fashion_cfgid)
  self.id = 12609356
  self.childid = childid or nil
  self.fashion_cfgid = fashion_cfgid or nil
end
function CUndressFashion:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.fashion_cfgid)
end
function CUndressFashion:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.fashion_cfgid = os:unmarshalInt32()
end
function CUndressFashion:sizepolicy(size)
  return size <= 65535
end
return CUndressFashion
