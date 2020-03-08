local SSetSwornTitleRes = class("SSetSwornTitleRes")
SSetSwornTitleRes.TYPEID = 12597765
SSetSwornTitleRes.SUCCESS = 0
SSetSwornTitleRes.ERROR_UNKNOWN = 1
SSetSwornTitleRes.ERROR_NAME = 2
function SSetSwornTitleRes:ctor(resultcode)
  self.id = 12597765
  self.resultcode = resultcode or nil
end
function SSetSwornTitleRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SSetSwornTitleRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SSetSwornTitleRes:sizepolicy(size)
  return size <= 65535
end
return SSetSwornTitleRes
