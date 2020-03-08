local SForbiddenTalkRes = class("SForbiddenTalkRes")
SForbiddenTalkRes.TYPEID = 12589859
function SForbiddenTalkRes:ctor(costVigor, leftTime)
  self.id = 12589859
  self.costVigor = costVigor or nil
  self.leftTime = leftTime or nil
end
function SForbiddenTalkRes:marshal(os)
  os:marshalInt32(self.costVigor)
  os:marshalInt32(self.leftTime)
end
function SForbiddenTalkRes:unmarshal(os)
  self.costVigor = os:unmarshalInt32()
  self.leftTime = os:unmarshalInt32()
end
function SForbiddenTalkRes:sizepolicy(size)
  return size <= 65535
end
return SForbiddenTalkRes
