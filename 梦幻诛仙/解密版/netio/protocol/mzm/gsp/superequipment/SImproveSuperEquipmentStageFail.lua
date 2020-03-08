local SImproveSuperEquipmentStageFail = class("SImproveSuperEquipmentStageFail")
SImproveSuperEquipmentStageFail.TYPEID = 12618758
SImproveSuperEquipmentStageFail.NO_MATERIAL = 1
SImproveSuperEquipmentStageFail.INSUFFICIENT_YUANBAO = 2
SImproveSuperEquipmentStageFail.INSUFFICIENT_CURRENCY = 3
SImproveSuperEquipmentStageFail.YUANBAO_MISMATCH = 4
SImproveSuperEquipmentStageFail.CURRENCY_MISMATCH = 5
function SImproveSuperEquipmentStageFail:ctor(retcode)
  self.id = 12618758
  self.retcode = retcode or nil
end
function SImproveSuperEquipmentStageFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SImproveSuperEquipmentStageFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SImproveSuperEquipmentStageFail:sizepolicy(size)
  return size <= 65535
end
return SImproveSuperEquipmentStageFail
