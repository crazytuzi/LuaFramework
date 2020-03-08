local SChangeSwornTitleFailRes = class("SChangeSwornTitleFailRes")
SChangeSwornTitleFailRes.TYPEID = 12597779
SChangeSwornTitleFailRes.ERROR_UNKNOWN = 1
SChangeSwornTitleFailRes.ERROR_NAME = 2
SChangeSwornTitleFailRes.ERROR_SILVER_NOT_ENOUGH = 3
function SChangeSwornTitleFailRes:ctor(resultcode)
  self.id = 12597779
  self.resultcode = resultcode or nil
end
function SChangeSwornTitleFailRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SChangeSwornTitleFailRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SChangeSwornTitleFailRes:sizepolicy(size)
  return size <= 65535
end
return SChangeSwornTitleFailRes
