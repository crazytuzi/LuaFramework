local SCreateItemSuccess = class("SCreateItemSuccess")
SCreateItemSuccess.TYPEID = 12623875
function SCreateItemSuccess:ctor(activity_id, create_item_id, create_num, action_type)
  self.id = 12623875
  self.activity_id = activity_id or nil
  self.create_item_id = create_item_id or nil
  self.create_num = create_num or nil
  self.action_type = action_type or nil
end
function SCreateItemSuccess:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.create_item_id)
  os:marshalInt32(self.create_num)
  os:marshalInt32(self.action_type)
end
function SCreateItemSuccess:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.create_item_id = os:unmarshalInt32()
  self.create_num = os:unmarshalInt32()
  self.action_type = os:unmarshalInt32()
end
function SCreateItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SCreateItemSuccess
