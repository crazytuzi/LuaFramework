local SOpenChestSuccess = class("SOpenChestSuccess")
SOpenChestSuccess.TYPEID = 12612871
function SOpenChestSuccess:ctor(activity_cfg_id, grid, makerid)
  self.id = 12612871
  self.activity_cfg_id = activity_cfg_id or nil
  self.grid = grid or nil
  self.makerid = makerid or nil
end
function SOpenChestSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.grid)
  os:marshalInt64(self.makerid)
end
function SOpenChestSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
  self.makerid = os:unmarshalInt64()
end
function SOpenChestSuccess:sizepolicy(size)
  return size <= 65535
end
return SOpenChestSuccess
