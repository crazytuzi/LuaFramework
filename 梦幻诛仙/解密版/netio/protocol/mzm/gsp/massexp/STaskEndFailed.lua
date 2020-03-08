local STaskEndFailed = class("STaskEndFailed")
STaskEndFailed.TYPEID = 12608258
STaskEndFailed.ERROR_NOT_JOIN_ACTIVITY = -1
function STaskEndFailed:ctor(retcode)
  self.id = 12608258
  self.retcode = retcode or nil
end
function STaskEndFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function STaskEndFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function STaskEndFailed:sizepolicy(size)
  return size <= 65535
end
return STaskEndFailed
