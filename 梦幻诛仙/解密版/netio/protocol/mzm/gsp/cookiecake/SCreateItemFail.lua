local SCreateItemFail = class("SCreateItemFail")
SCreateItemFail.TYPEID = 12623873
SCreateItemFail.ERROR_SYSTEM = 1
SCreateItemFail.ERROR_USERID = 2
SCreateItemFail.ERROR_CFG = 3
SCreateItemFail.ERROR_PARAM = 4
SCreateItemFail.ERROR_CAN_NOT_JOIN_ACTIVITY = 5
SCreateItemFail.ERROR_BAG_FULL = 6
SCreateItemFail.ERROR_COST_ITEM_LESS = 7
function SCreateItemFail:ctor(activity_id, create_item_id, action_type, error_code)
  self.id = 12623873
  self.activity_id = activity_id or nil
  self.create_item_id = create_item_id or nil
  self.action_type = action_type or nil
  self.error_code = error_code or nil
end
function SCreateItemFail:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.create_item_id)
  os:marshalInt32(self.action_type)
  os:marshalInt32(self.error_code)
end
function SCreateItemFail:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.create_item_id = os:unmarshalInt32()
  self.action_type = os:unmarshalInt32()
  self.error_code = os:unmarshalInt32()
end
function SCreateItemFail:sizepolicy(size)
  return size <= 65535
end
return SCreateItemFail
