local SSynMassWeddingStageChange = class("SSynMassWeddingStageChange")
SSynMassWeddingStageChange.TYPEID = 12604958
function SSynMassWeddingStageChange:ctor(stage)
  self.id = 12604958
  self.stage = stage or nil
end
function SSynMassWeddingStageChange:marshal(os)
  os:marshalInt32(self.stage)
end
function SSynMassWeddingStageChange:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function SSynMassWeddingStageChange:sizepolicy(size)
  return size <= 65535
end
return SSynMassWeddingStageChange
