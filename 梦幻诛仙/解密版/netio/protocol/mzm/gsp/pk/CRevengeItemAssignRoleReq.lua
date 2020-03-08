local CRevengeItemAssignRoleReq = class("CRevengeItemAssignRoleReq")
CRevengeItemAssignRoleReq.TYPEID = 12619779
function CRevengeItemAssignRoleReq:ctor(bag_id, grid, role_id_or_name)
  self.id = 12619779
  self.bag_id = bag_id or nil
  self.grid = grid or nil
  self.role_id_or_name = role_id_or_name or nil
end
function CRevengeItemAssignRoleReq:marshal(os)
  os:marshalInt32(self.bag_id)
  os:marshalInt32(self.grid)
  os:marshalString(self.role_id_or_name)
end
function CRevengeItemAssignRoleReq:unmarshal(os)
  self.bag_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.role_id_or_name = os:unmarshalString()
end
function CRevengeItemAssignRoleReq:sizepolicy(size)
  return size <= 65535
end
return CRevengeItemAssignRoleReq
