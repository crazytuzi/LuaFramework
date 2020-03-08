local SNotifyRoundChange = class("SNotifyRoundChange")
SNotifyRoundChange.TYPEID = 12619039
function SNotifyRoundChange:ctor(round)
  self.id = 12619039
  self.round = round or nil
end
function SNotifyRoundChange:marshal(os)
  os:marshalInt32(self.round)
end
function SNotifyRoundChange:unmarshal(os)
  self.round = os:unmarshalInt32()
end
function SNotifyRoundChange:sizepolicy(size)
  return size <= 65535
end
return SNotifyRoundChange
