local SChangePartnerFailed = class("SChangePartnerFailed")
SChangePartnerFailed.TYPEID = 12605701
SChangePartnerFailed.ERROR_GOLD_NOT_ENOUGH = -1
function SChangePartnerFailed:ctor(retcode)
  self.id = 12605701
  self.retcode = retcode or nil
end
function SChangePartnerFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SChangePartnerFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SChangePartnerFailed:sizepolicy(size)
  return size <= 65535
end
return SChangePartnerFailed
