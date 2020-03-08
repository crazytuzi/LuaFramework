local SChooseInterestFailed = class("SChooseInterestFailed")
SChooseInterestFailed.TYPEID = 12609300
SChooseInterestFailed.ERROR_MOENTY_NOT_ENOUGH = -1
function SChooseInterestFailed:ctor(childid, retcode)
  self.id = 12609300
  self.childid = childid or nil
  self.retcode = retcode or nil
end
function SChooseInterestFailed:marshal(os)
  os:marshalInt64(self.childid)
  os:marshalInt32(self.retcode)
end
function SChooseInterestFailed:unmarshal(os)
  self.childid = os:unmarshalInt64()
  self.retcode = os:unmarshalInt32()
end
function SChooseInterestFailed:sizepolicy(size)
  return size <= 65535
end
return SChooseInterestFailed
