local STransferSuperEquipmentFail = class("STransferSuperEquipmentFail")
STransferSuperEquipmentFail.TYPEID = 12618754
STransferSuperEquipmentFail.STAGE_CONDITIONS_NOT_MEET = 1
STransferSuperEquipmentFail.LEVEL_CONDITIONS_NOT_MEET = 2
function STransferSuperEquipmentFail:ctor(retcode)
  self.id = 12618754
  self.retcode = retcode or nil
end
function STransferSuperEquipmentFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function STransferSuperEquipmentFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function STransferSuperEquipmentFail:sizepolicy(size)
  return size <= 65535
end
return STransferSuperEquipmentFail
