local SGetLoginSignAwardFailed = class("SGetLoginSignAwardFailed")
SGetLoginSignAwardFailed.TYPEID = 12604686
SGetLoginSignAwardFailed.ERROR_NOT_OPEN = -1
SGetLoginSignAwardFailed.ERROR_AWARD_HAVE_RECEIVED = -2
SGetLoginSignAwardFailed.ERROR_NOT_MATCH = -3
SGetLoginSignAwardFailed.ERROR_LEVEL_LIMIT = -4
SGetLoginSignAwardFailed.ERROR_EXPIRE = -5
function SGetLoginSignAwardFailed:ctor(activity_cfgid, sortid, retcode)
  self.id = 12604686
  self.activity_cfgid = activity_cfgid or nil
  self.sortid = sortid or nil
  self.retcode = retcode or nil
end
function SGetLoginSignAwardFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.retcode)
end
function SGetLoginSignAwardFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetLoginSignAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetLoginSignAwardFailed
