local CUseFriendsCircleOrnamentItem = class("CUseFriendsCircleOrnamentItem")
CUseFriendsCircleOrnamentItem.TYPEID = 12625424
function CUseFriendsCircleOrnamentItem:ctor(item_uuid)
  self.id = 12625424
  self.item_uuid = item_uuid or nil
end
function CUseFriendsCircleOrnamentItem:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUseFriendsCircleOrnamentItem:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUseFriendsCircleOrnamentItem:sizepolicy(size)
  return size <= 65535
end
return CUseFriendsCircleOrnamentItem
