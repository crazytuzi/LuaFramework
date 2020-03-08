local SSynStageChange = class("SSynStageChange")
SSynStageChange.TYPEID = 12601864
SSynStageChange.STATUS_PREPARE_0 = 0
SSynStageChange.STATUS_MATCH_1 = 1
SSynStageChange.STATUS_MATCH_END_2 = 2
function SSynStageChange:ctor(stage)
  self.id = 12601864
  self.stage = stage or nil
end
function SSynStageChange:marshal(os)
  os:marshalInt32(self.stage)
end
function SSynStageChange:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function SSynStageChange:sizepolicy(size)
  return size <= 65535
end
return SSynStageChange
