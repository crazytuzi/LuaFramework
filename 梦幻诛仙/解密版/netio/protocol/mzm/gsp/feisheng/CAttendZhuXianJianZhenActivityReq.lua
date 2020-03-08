local CAttendZhuXianJianZhenActivityReq = class("CAttendZhuXianJianZhenActivityReq")
CAttendZhuXianJianZhenActivityReq.TYPEID = 12614152
function CAttendZhuXianJianZhenActivityReq:ctor(activity_cfg_id)
  self.id = 12614152
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendZhuXianJianZhenActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendZhuXianJianZhenActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendZhuXianJianZhenActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendZhuXianJianZhenActivityReq
