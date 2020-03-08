local SUseAxeItemSuccess = class("SUseAxeItemSuccess")
SUseAxeItemSuccess.TYPEID = 12584867
function SUseAxeItemSuccess:ctor(axe_item_cfg_id, grid, num)
  self.id = 12584867
  self.axe_item_cfg_id = axe_item_cfg_id or nil
  self.grid = grid or nil
  self.num = num or nil
end
function SUseAxeItemSuccess:marshal(os)
  os:marshalInt32(self.axe_item_cfg_id)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.num)
end
function SUseAxeItemSuccess:unmarshal(os)
  self.axe_item_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function SUseAxeItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseAxeItemSuccess
