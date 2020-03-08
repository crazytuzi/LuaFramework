local SSynDoudouComeoutStagetRes = class("SSynDoudouComeoutStagetRes")
SSynDoudouComeoutStagetRes.TYPEID = 12608777
function SSynDoudouComeoutStagetRes:ctor(seed, turn)
  self.id = 12608777
  self.seed = seed or nil
  self.turn = turn or nil
end
function SSynDoudouComeoutStagetRes:marshal(os)
  os:marshalInt32(self.seed)
  os:marshalInt32(self.turn)
end
function SSynDoudouComeoutStagetRes:unmarshal(os)
  self.seed = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
end
function SSynDoudouComeoutStagetRes:sizepolicy(size)
  return size <= 65535
end
return SSynDoudouComeoutStagetRes
