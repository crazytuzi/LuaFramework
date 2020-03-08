local CImproveSuperEquipmentStageReq = class("CImproveSuperEquipmentStageReq")
CImproveSuperEquipmentStageReq.TYPEID = 12618753
function CImproveSuperEquipmentStageReq:ctor(bag_id, grid, use_yuanbao, required_yuanbao, currency)
  self.id = 12618753
  self.bag_id = bag_id or nil
  self.grid = grid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.required_yuanbao = required_yuanbao or nil
  self.currency = currency or nil
end
function CImproveSuperEquipmentStageReq:marshal(os)
  os:marshalInt32(self.bag_id)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.use_yuanbao)
  os:marshalInt64(self.required_yuanbao)
  os:marshalInt64(self.currency)
end
function CImproveSuperEquipmentStageReq:unmarshal(os)
  self.bag_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalInt32()
  self.required_yuanbao = os:unmarshalInt64()
  self.currency = os:unmarshalInt64()
end
function CImproveSuperEquipmentStageReq:sizepolicy(size)
  return size <= 65535
end
return CImproveSuperEquipmentStageReq
