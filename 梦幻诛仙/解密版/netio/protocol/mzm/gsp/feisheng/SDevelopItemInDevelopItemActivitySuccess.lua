local SDevelopItemInDevelopItemActivitySuccess = class("SDevelopItemInDevelopItemActivitySuccess")
SDevelopItemInDevelopItemActivitySuccess.TYPEID = 12614174
function SDevelopItemInDevelopItemActivitySuccess:ctor(activity_cfg_id, grid, real_add_extra_value)
  self.id = 12614174
  self.activity_cfg_id = activity_cfg_id or nil
  self.grid = grid or nil
  self.real_add_extra_value = real_add_extra_value or nil
end
function SDevelopItemInDevelopItemActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.real_add_extra_value)
end
function SDevelopItemInDevelopItemActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.real_add_extra_value = os:unmarshalInt32()
end
function SDevelopItemInDevelopItemActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SDevelopItemInDevelopItemActivitySuccess
