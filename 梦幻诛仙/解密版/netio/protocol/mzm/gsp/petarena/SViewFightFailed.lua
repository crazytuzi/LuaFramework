local SViewFightFailed = class("SViewFightFailed")
SViewFightFailed.TYPEID = 12628248
SViewFightFailed.ERROR_NOT_FOUND = -1
SViewFightFailed.ERROR_ACTIVITY_JOIN = -2
SViewFightFailed.ERROR_IN_TEAM = -3
function SViewFightFailed:ctor(recordid, retcode)
  self.id = 12628248
  self.recordid = recordid or nil
  self.retcode = retcode or nil
end
function SViewFightFailed:marshal(os)
  os:marshalInt64(self.recordid)
  os:marshalInt32(self.retcode)
end
function SViewFightFailed:unmarshal(os)
  self.recordid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SViewFightFailed:sizepolicy(size)
  return size <= 65535
end
return SViewFightFailed
