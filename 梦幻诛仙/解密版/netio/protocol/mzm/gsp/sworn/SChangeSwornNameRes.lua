local SChangeSwornNameRes = class("SChangeSwornNameRes")
SChangeSwornNameRes.TYPEID = 12597801
SChangeSwornNameRes.SUCCESS = 0
SChangeSwornNameRes.ERROR_UNKNOWN = 1
SChangeSwornNameRes.ERROR_NAME = 2
SChangeSwornNameRes.ERROR_SILVER_NOT_ENOUGH = 3
SChangeSwornNameRes.ERROR_NOT_SWORN = 4
SChangeSwornNameRes.ERROR_VOTEING = 5
SChangeSwornNameRes.ERROR_NOT_AGREE = 6
function SChangeSwornNameRes:ctor(resultcode)
  self.id = 12597801
  self.resultcode = resultcode or nil
end
function SChangeSwornNameRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SChangeSwornNameRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SChangeSwornNameRes:sizepolicy(size)
  return size <= 65535
end
return SChangeSwornNameRes
