local CCommitItemInDevelopItemActivityReq = class("CCommitItemInDevelopItemActivityReq")
CCommitItemInDevelopItemActivityReq.TYPEID = 12614151
function CCommitItemInDevelopItemActivityReq:ctor(activity_cfg_id, grid)
  self.id = 12614151
  self.activity_cfg_id = activity_cfg_id or nil
  self.grid = grid or nil
end
function CCommitItemInDevelopItemActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.grid)
end
function CCommitItemInDevelopItemActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
end
function CCommitItemInDevelopItemActivityReq:sizepolicy(size)
  return size <= 65535
end
return CCommitItemInDevelopItemActivityReq
