local SUseFriendsCircleOrnamentItemSuccess = class("SUseFriendsCircleOrnamentItemSuccess")
SUseFriendsCircleOrnamentItemSuccess.TYPEID = 12625412
function SUseFriendsCircleOrnamentItemSuccess:ctor(add_item_cfg_id)
  self.id = 12625412
  self.add_item_cfg_id = add_item_cfg_id or nil
end
function SUseFriendsCircleOrnamentItemSuccess:marshal(os)
  os:marshalInt32(self.add_item_cfg_id)
end
function SUseFriendsCircleOrnamentItemSuccess:unmarshal(os)
  self.add_item_cfg_id = os:unmarshalInt32()
end
function SUseFriendsCircleOrnamentItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseFriendsCircleOrnamentItemSuccess
