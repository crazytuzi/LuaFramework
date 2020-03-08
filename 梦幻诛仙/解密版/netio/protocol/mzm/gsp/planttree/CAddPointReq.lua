local CAddPointReq = class("CAddPointReq")
CAddPointReq.TYPEID = 12611592
function CAddPointReq:ctor(activity_cfg_id, add_point_operation_cfg_id, money_type, money_num)
  self.id = 12611592
  self.activity_cfg_id = activity_cfg_id or nil
  self.add_point_operation_cfg_id = add_point_operation_cfg_id or nil
  self.money_type = money_type or nil
  self.money_num = money_num or nil
end
function CAddPointReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.add_point_operation_cfg_id)
  os:marshalInt32(self.money_type)
  os:marshalInt32(self.money_num)
end
function CAddPointReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.add_point_operation_cfg_id = os:unmarshalInt32()
  self.money_type = os:unmarshalInt32()
  self.money_num = os:unmarshalInt32()
end
function CAddPointReq:sizepolicy(size)
  return size <= 65535
end
return CAddPointReq
