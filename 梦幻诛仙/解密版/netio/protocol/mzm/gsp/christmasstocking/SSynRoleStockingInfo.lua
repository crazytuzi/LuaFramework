local SSynRoleStockingInfo = class("SSynRoleStockingInfo")
SSynRoleStockingInfo.TYPEID = 12629517
function SSynRoleStockingInfo:ctor(total_hang_num)
  self.id = 12629517
  self.total_hang_num = total_hang_num or nil
end
function SSynRoleStockingInfo:marshal(os)
  os:marshalInt32(self.total_hang_num)
end
function SSynRoleStockingInfo:unmarshal(os)
  self.total_hang_num = os:unmarshalInt32()
end
function SSynRoleStockingInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleStockingInfo
