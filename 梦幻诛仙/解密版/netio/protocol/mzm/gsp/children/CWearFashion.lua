local CWearFashion = class("CWearFashion")
CWearFashion.TYPEID = 12609360
function CWearFashion:ctor(childid, fashion_cfgid)
  self.id = 12609360
  self.childid = childid or nil
  self.fashion_cfgid = fashion_cfgid or nil
end
function CWearFashion:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.fashion_cfgid)
end
function CWearFashion:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.fashion_cfgid = os:unmarshalInt32()
end
function CWearFashion:sizepolicy(size)
  return size <= 65535
end
return CWearFashion
