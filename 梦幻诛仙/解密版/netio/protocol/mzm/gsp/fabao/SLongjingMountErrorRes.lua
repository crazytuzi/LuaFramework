local SLongjingMountErrorRes = class("SLongjingMountErrorRes")
SLongjingMountErrorRes.TYPEID = 12596007
SLongjingMountErrorRes.ERROR_UNKNOWN = 0
SLongjingMountErrorRes.ERROR_LONGJING_ITEM = 1
SLongjingMountErrorRes.ERROR_HOLE_NUM_ERROR = 2
SLongjingMountErrorRes.ERROR_IN_CROSS = 3
function SLongjingMountErrorRes:ctor(resultcode)
  self.id = 12596007
  self.resultcode = resultcode or nil
end
function SLongjingMountErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLongjingMountErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLongjingMountErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingMountErrorRes
