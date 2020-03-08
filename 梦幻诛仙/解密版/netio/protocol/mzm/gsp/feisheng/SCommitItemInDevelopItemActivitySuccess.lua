local SCommitItemInDevelopItemActivitySuccess = class("SCommitItemInDevelopItemActivitySuccess")
SCommitItemInDevelopItemActivitySuccess.TYPEID = 12614155
function SCommitItemInDevelopItemActivitySuccess:ctor(activity_cfg_id, grid)
  self.id = 12614155
  self.activity_cfg_id = activity_cfg_id or nil
  self.grid = grid or nil
end
function SCommitItemInDevelopItemActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.grid)
end
function SCommitItemInDevelopItemActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.grid = os:unmarshalInt32()
end
function SCommitItemInDevelopItemActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SCommitItemInDevelopItemActivitySuccess
