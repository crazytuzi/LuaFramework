local CImproveSuperEquipmentLevelReq = class("CImproveSuperEquipmentLevelReq")
CImproveSuperEquipmentLevelReq.TYPEID = 12618756
function CImproveSuperEquipmentLevelReq:ctor(bag_id, grid, use_yuanbao, required_yuanbao, currency)
  self.id = 12618756
  self.bag_id = bag_id or nil
  self.grid = grid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.required_yuanbao = required_yuanbao or nil
  self.currency = currency or nil
end
function CImproveSuperEquipmentLevelReq:marshal(os)
  os:marshalInt32(self.bag_id)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.use_yuanbao)
  os:marshalInt64(self.required_yuanbao)
  os:marshalInt64(self.currency)
end
function CImproveSuperEquipmentLevelReq:unmarshal(os)
  self.bag_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalInt32()
  self.required_yuanbao = os:unmarshalInt64()
  self.currency = os:unmarshalInt64()
end
function CImproveSuperEquipmentLevelReq:sizepolicy(size)
  return size <= 65535
end
return CImproveSuperEquipmentLevelReq
