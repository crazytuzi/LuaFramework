local CBuyFashion = class("CBuyFashion")
CBuyFashion.TYPEID = 12609361
function CBuyFashion:ctor(fashion_cfgid)
  self.id = 12609361
  self.fashion_cfgid = fashion_cfgid or nil
end
function CBuyFashion:marshal(os)
  os:marshalInt32(self.fashion_cfgid)
end
function CBuyFashion:unmarshal(os)
  self.fashion_cfgid = os:unmarshalInt32()
end
function CBuyFashion:sizepolicy(size)
  return size <= 65535
end
return CBuyFashion
