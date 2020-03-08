local SChangeToNormalMatch = class("SChangeToNormalMatch")
SChangeToNormalMatch.TYPEID = 12593681
SChangeToNormalMatch.TIME_OUT__CHANGE = 1
SChangeToNormalMatch.NEW_ENOUGH__CHANGE = 2
function SChangeToNormalMatch:ctor(changeType)
  self.id = 12593681
  self.changeType = changeType or nil
end
function SChangeToNormalMatch:marshal(os)
  os:marshalInt32(self.changeType)
end
function SChangeToNormalMatch:unmarshal(os)
  self.changeType = os:unmarshalInt32()
end
function SChangeToNormalMatch:sizepolicy(size)
  return size <= 65535
end
return SChangeToNormalMatch
