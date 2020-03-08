local SCommitItemInZhuXianJianZhenActivitySuccess = class("SCommitItemInZhuXianJianZhenActivitySuccess")
SCommitItemInZhuXianJianZhenActivitySuccess.TYPEID = 12614169
function SCommitItemInZhuXianJianZhenActivitySuccess:ctor(activity_cfg_id, real_commit_num, commit_item_num)
  self.id = 12614169
  self.activity_cfg_id = activity_cfg_id or nil
  self.real_commit_num = real_commit_num or nil
  self.commit_item_num = commit_item_num or nil
end
function SCommitItemInZhuXianJianZhenActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.real_commit_num)
  os:marshalInt32(self.commit_item_num)
end
function SCommitItemInZhuXianJianZhenActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.real_commit_num = os:unmarshalInt32()
  self.commit_item_num = os:unmarshalInt32()
end
function SCommitItemInZhuXianJianZhenActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SCommitItemInZhuXianJianZhenActivitySuccess
