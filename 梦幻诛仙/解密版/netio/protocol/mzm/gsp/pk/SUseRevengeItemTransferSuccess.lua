local SUseRevengeItemTransferSuccess = class("SUseRevengeItemTransferSuccess")
SUseRevengeItemTransferSuccess.TYPEID = 12619781
function SUseRevengeItemTransferSuccess:ctor(target_role_id, target_role_name)
  self.id = 12619781
  self.target_role_id = target_role_id or nil
  self.target_role_name = target_role_name or nil
end
function SUseRevengeItemTransferSuccess:marshal(os)
  os:marshalInt64(self.target_role_id)
  os:marshalOctets(self.target_role_name)
end
function SUseRevengeItemTransferSuccess:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
  self.target_role_name = os:unmarshalOctets()
end
function SUseRevengeItemTransferSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseRevengeItemTransferSuccess
