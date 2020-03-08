local SLeaveSwornRes = class("SLeaveSwornRes")
SLeaveSwornRes.TYPEID = 12597804
SLeaveSwornRes.SUCCESS = 0
SLeaveSwornRes.ERROR_UNKNOWN = 1
SLeaveSwornRes.ERROR_NO_SWORN = 2
function SLeaveSwornRes:ctor(resultcode)
  self.id = 12597804
  self.resultcode = resultcode or nil
end
function SLeaveSwornRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLeaveSwornRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLeaveSwornRes:sizepolicy(size)
  return size <= 65535
end
return SLeaveSwornRes
