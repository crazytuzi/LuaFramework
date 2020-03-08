local CCreateItemReq = class("CCreateItemReq")
CCreateItemReq.TYPEID = 12623874
CCreateItemReq.CREATE_ONE = 1
CCreateItemReq.CREATE_ALL = 2
function CCreateItemReq:ctor(activity_id, create_item_id, action_type)
  self.id = 12623874
  self.activity_id = activity_id or nil
  self.create_item_id = create_item_id or nil
  self.action_type = action_type or nil
end
function CCreateItemReq:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.create_item_id)
  os:marshalInt32(self.action_type)
end
function CCreateItemReq:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.create_item_id = os:unmarshalInt32()
  self.action_type = os:unmarshalInt32()
end
function CCreateItemReq:sizepolicy(size)
  return size <= 65535
end
return CCreateItemReq
