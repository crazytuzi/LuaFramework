local SAddPointSuccess = class("SAddPointSuccess")
SAddPointSuccess.TYPEID = 12611591
function SAddPointSuccess:ctor(activity_cfg_id, add_point_operation_cfg_id)
  self.id = 12611591
  self.activity_cfg_id = activity_cfg_id or nil
  self.add_point_operation_cfg_id = add_point_operation_cfg_id or nil
end
function SAddPointSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.add_point_operation_cfg_id)
end
function SAddPointSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.add_point_operation_cfg_id = os:unmarshalInt32()
end
function SAddPointSuccess:sizepolicy(size)
  return size <= 65535
end
return SAddPointSuccess
