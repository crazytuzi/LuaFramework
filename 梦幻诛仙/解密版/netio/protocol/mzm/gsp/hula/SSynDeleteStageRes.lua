local SSynDeleteStageRes = class("SSynDeleteStageRes")
SSynDeleteStageRes.TYPEID = 12608775
function SSynDeleteStageRes:ctor(turn)
  self.id = 12608775
  self.turn = turn or nil
end
function SSynDeleteStageRes:marshal(os)
  os:marshalInt32(self.turn)
end
function SSynDeleteStageRes:unmarshal(os)
  self.turn = os:unmarshalInt32()
end
function SSynDeleteStageRes:sizepolicy(size)
  return size <= 65535
end
return SSynDeleteStageRes
