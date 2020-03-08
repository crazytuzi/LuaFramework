local CLeaveZhuXianJianZhenActivityMapReq = class("CLeaveZhuXianJianZhenActivityMapReq")
CLeaveZhuXianJianZhenActivityMapReq.TYPEID = 12614176
function CLeaveZhuXianJianZhenActivityMapReq:ctor(activity_cfg_id)
  self.id = 12614176
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveZhuXianJianZhenActivityMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveZhuXianJianZhenActivityMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveZhuXianJianZhenActivityMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveZhuXianJianZhenActivityMapReq
