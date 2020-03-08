local SSyncRemoveFashionInfo = class("SSyncRemoveFashionInfo")
SSyncRemoveFashionInfo.TYPEID = 12609362
function SSyncRemoveFashionInfo:ctor(fashion_cfgid)
  self.id = 12609362
  self.fashion_cfgid = fashion_cfgid or nil
end
function SSyncRemoveFashionInfo:marshal(os)
  os:marshalInt32(self.fashion_cfgid)
end
function SSyncRemoveFashionInfo:unmarshal(os)
  self.fashion_cfgid = os:unmarshalInt32()
end
function SSyncRemoveFashionInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRemoveFashionInfo
