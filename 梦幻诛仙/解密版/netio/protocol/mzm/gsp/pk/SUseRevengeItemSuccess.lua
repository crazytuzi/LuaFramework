local SUseRevengeItemSuccess = class("SUseRevengeItemSuccess")
SUseRevengeItemSuccess.TYPEID = 12619793
function SUseRevengeItemSuccess:ctor(map_id, pos_x, pos_y)
  self.id = 12619793
  self.map_id = map_id or nil
  self.pos_x = pos_x or nil
  self.pos_y = pos_y or nil
end
function SUseRevengeItemSuccess:marshal(os)
  os:marshalInt32(self.map_id)
  os:marshalInt32(self.pos_x)
  os:marshalInt32(self.pos_y)
end
function SUseRevengeItemSuccess:unmarshal(os)
  self.map_id = os:unmarshalInt32()
  self.pos_x = os:unmarshalInt32()
  self.pos_y = os:unmarshalInt32()
end
function SUseRevengeItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseRevengeItemSuccess
