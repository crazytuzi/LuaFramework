local SAdvertsFailed = class("SAdvertsFailed")
SAdvertsFailed.TYPEID = 12603668
function SAdvertsFailed:ctor(retcode)
  self.id = 12603668
  self.retcode = retcode or nil
end
function SAdvertsFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SAdvertsFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SAdvertsFailed:sizepolicy(size)
  return size <= 65535
end
return SAdvertsFailed
