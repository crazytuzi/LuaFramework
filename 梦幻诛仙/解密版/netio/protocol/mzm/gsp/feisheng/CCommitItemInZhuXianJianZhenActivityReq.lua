local CCommitItemInZhuXianJianZhenActivityReq = class("CCommitItemInZhuXianJianZhenActivityReq")
CCommitItemInZhuXianJianZhenActivityReq.TYPEID = 12614159
function CCommitItemInZhuXianJianZhenActivityReq:ctor(activity_cfg_id)
  self.id = 12614159
  self.activity_cfg_id = activity_cfg_id or nil
end
function CCommitItemInZhuXianJianZhenActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CCommitItemInZhuXianJianZhenActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CCommitItemInZhuXianJianZhenActivityReq:sizepolicy(size)
  return size <= 65535
end
return CCommitItemInZhuXianJianZhenActivityReq
