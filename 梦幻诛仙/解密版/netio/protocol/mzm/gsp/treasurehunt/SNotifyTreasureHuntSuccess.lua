local SNotifyTreasureHuntSuccess = class("SNotifyTreasureHuntSuccess")
SNotifyTreasureHuntSuccess.TYPEID = 12633089
function SNotifyTreasureHuntSuccess:ctor(effect_id)
  self.id = 12633089
  self.effect_id = effect_id or nil
end
function SNotifyTreasureHuntSuccess:marshal(os)
  os:marshalInt32(self.effect_id)
end
function SNotifyTreasureHuntSuccess:unmarshal(os)
  self.effect_id = os:unmarshalInt32()
end
function SNotifyTreasureHuntSuccess:sizepolicy(size)
  return size <= 65535
end
return SNotifyTreasureHuntSuccess
