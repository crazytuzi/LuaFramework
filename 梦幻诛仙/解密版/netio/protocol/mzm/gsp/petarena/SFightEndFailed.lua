local SFightEndFailed = class("SFightEndFailed")
SFightEndFailed.TYPEID = 12628253
SFightEndFailed.ERROR_AWARD = -1
function SFightEndFailed:ctor(retcode)
  self.id = 12628253
  self.retcode = retcode or nil
end
function SFightEndFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SFightEndFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SFightEndFailed:sizepolicy(size)
  return size <= 65535
end
return SFightEndFailed
