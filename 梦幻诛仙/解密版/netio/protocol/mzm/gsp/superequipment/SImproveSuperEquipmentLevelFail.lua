local SImproveSuperEquipmentLevelFail = class("SImproveSuperEquipmentLevelFail")
SImproveSuperEquipmentLevelFail.TYPEID = 12618760
SImproveSuperEquipmentLevelFail.NO_MATERIAL = 1
SImproveSuperEquipmentLevelFail.INSUFFICIENT_YUANBAO = 2
SImproveSuperEquipmentLevelFail.INSUFFICIENT_CURRENCY = 3
SImproveSuperEquipmentLevelFail.YUANBAO_MISMATCH = 4
SImproveSuperEquipmentLevelFail.CURRENCY_MISMATCH = 5
function SImproveSuperEquipmentLevelFail:ctor(retcode)
  self.id = 12618760
  self.retcode = retcode or nil
end
function SImproveSuperEquipmentLevelFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SImproveSuperEquipmentLevelFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SImproveSuperEquipmentLevelFail:sizepolicy(size)
  return size <= 65535
end
return SImproveSuperEquipmentLevelFail
