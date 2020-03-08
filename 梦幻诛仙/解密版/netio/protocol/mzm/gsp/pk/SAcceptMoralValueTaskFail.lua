local SAcceptMoralValueTaskFail = class("SAcceptMoralValueTaskFail")
SAcceptMoralValueTaskFail.TYPEID = 12619787
SAcceptMoralValueTaskFail.MORAL_VALUE_FULL = 1
function SAcceptMoralValueTaskFail:ctor(retcode)
  self.id = 12619787
  self.retcode = retcode or nil
end
function SAcceptMoralValueTaskFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SAcceptMoralValueTaskFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SAcceptMoralValueTaskFail:sizepolicy(size)
  return size <= 65535
end
return SAcceptMoralValueTaskFail
