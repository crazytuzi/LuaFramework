local CDevelopItemInDevelopItemActivityReq = class("CDevelopItemInDevelopItemActivityReq")
CDevelopItemInDevelopItemActivityReq.TYPEID = 12614175
function CDevelopItemInDevelopItemActivityReq:ctor(activity_cfg_id, grid, add_extra_value)
  self.id = 12614175
  self.activity_cfg_id = activity_cfg_id or nil
  self.grid = grid or nil
  self.add_extra_value = add_extra_value or nil
end
function CDevelopItemInDevelopItemActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.grid)
  os:marshalInt32(self.add_extra_value)
end
function CDevelopItemInDevelopItemActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.add_extra_value = os:unmarshalInt32()
end
function CDevelopItemInDevelopItemActivityReq:sizepolicy(size)
  return size <= 65535
end
return CDevelopItemInDevelopItemActivityReq
