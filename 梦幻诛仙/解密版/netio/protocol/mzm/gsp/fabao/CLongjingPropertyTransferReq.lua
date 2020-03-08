local CLongjingPropertyTransferReq = class("CLongjingPropertyTransferReq")
CLongjingPropertyTransferReq.TYPEID = 12596034
function CLongjingPropertyTransferReq:ctor(toTransferItemUuid, targetproperty, targetitemid)
  self.id = 12596034
  self.toTransferItemUuid = toTransferItemUuid or nil
  self.targetproperty = targetproperty or nil
  self.targetitemid = targetitemid or nil
end
function CLongjingPropertyTransferReq:marshal(os)
  os:marshalInt64(self.toTransferItemUuid)
  os:marshalInt32(self.targetproperty)
  os:marshalInt32(self.targetitemid)
end
function CLongjingPropertyTransferReq:unmarshal(os)
  self.toTransferItemUuid = os:unmarshalInt64()
  self.targetproperty = os:unmarshalInt32()
  self.targetitemid = os:unmarshalInt32()
end
function CLongjingPropertyTransferReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingPropertyTransferReq
