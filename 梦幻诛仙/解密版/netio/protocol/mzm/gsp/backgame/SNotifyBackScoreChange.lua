local SNotifyBackScoreChange = class("SNotifyBackScoreChange")
SNotifyBackScoreChange.TYPEID = 12604418
function SNotifyBackScoreChange:ctor(now_back_score)
  self.id = 12604418
  self.now_back_score = now_back_score or nil
end
function SNotifyBackScoreChange:marshal(os)
  os:marshalInt32(self.now_back_score)
end
function SNotifyBackScoreChange:unmarshal(os)
  self.now_back_score = os:unmarshalInt32()
end
function SNotifyBackScoreChange:sizepolicy(size)
  return size <= 65535
end
return SNotifyBackScoreChange
