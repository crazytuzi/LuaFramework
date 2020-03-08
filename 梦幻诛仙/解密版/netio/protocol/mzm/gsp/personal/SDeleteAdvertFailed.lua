local SDeleteAdvertFailed = class("SDeleteAdvertFailed")
SDeleteAdvertFailed.TYPEID = 12603661
function SDeleteAdvertFailed:ctor(retcode)
  self.id = 12603661
  self.retcode = retcode or nil
end
function SDeleteAdvertFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SDeleteAdvertFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SDeleteAdvertFailed:sizepolicy(size)
  return size <= 65535
end
return SDeleteAdvertFailed
