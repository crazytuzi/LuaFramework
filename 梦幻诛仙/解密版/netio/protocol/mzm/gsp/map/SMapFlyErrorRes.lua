local SMapFlyErrorRes = class("SMapFlyErrorRes")
SMapFlyErrorRes.TYPEID = 12590927
SMapFlyErrorRes.ERROR_STATUS = 1
SMapFlyErrorRes.ERROR_MAP = 2
SMapFlyErrorRes.ERROR_NOT_HAVE_AIRCRAFT = 3
function SMapFlyErrorRes:ctor(ret)
  self.id = 12590927
  self.ret = ret or nil
end
function SMapFlyErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SMapFlyErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SMapFlyErrorRes:sizepolicy(size)
  return size <= 65535
end
return SMapFlyErrorRes
