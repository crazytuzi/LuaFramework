local SNextRoundBrd = class("SNextRoundBrd")
SNextRoundBrd.TYPEID = 12594190
function SNextRoundBrd:ctor(round)
  self.id = 12594190
  self.round = round or nil
end
function SNextRoundBrd:marshal(os)
  os:marshalInt32(self.round)
end
function SNextRoundBrd:unmarshal(os)
  self.round = os:unmarshalInt32()
end
function SNextRoundBrd:sizepolicy(size)
  return size <= 65535
end
return SNextRoundBrd
