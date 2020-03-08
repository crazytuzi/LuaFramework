local SReleaseAdvertFailed = class("SReleaseAdvertFailed")
SReleaseAdvertFailed.TYPEID = 12603669
function SReleaseAdvertFailed:ctor(retcode)
  self.id = 12603669
  self.retcode = retcode or nil
end
function SReleaseAdvertFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SReleaseAdvertFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SReleaseAdvertFailed:sizepolicy(size)
  return size <= 65535
end
return SReleaseAdvertFailed
