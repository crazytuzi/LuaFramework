local SLongjingUnMountErrorRes = class("SLongjingUnMountErrorRes")
SLongjingUnMountErrorRes.TYPEID = 12596012
SLongjingUnMountErrorRes.ERROR_UNKNOWN = 0
SLongjingUnMountErrorRes.ERROR_HOLE_EMPTY = 1
SLongjingUnMountErrorRes.ERROR_BAG_FULL = 2
SLongjingUnMountErrorRes.ERROR_IN_CROSS = 3
function SLongjingUnMountErrorRes:ctor(resultcode)
  self.id = 12596012
  self.resultcode = resultcode or nil
end
function SLongjingUnMountErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLongjingUnMountErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLongjingUnMountErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingUnMountErrorRes
