local CGetGrcFriendList = class("CGetGrcFriendList")
CGetGrcFriendList.TYPEID = 12600342
function CGetGrcFriendList:ctor(page_index)
  self.id = 12600342
  self.page_index = page_index or nil
end
function CGetGrcFriendList:marshal(os)
  os:marshalInt32(self.page_index)
end
function CGetGrcFriendList:unmarshal(os)
  self.page_index = os:unmarshalInt32()
end
function CGetGrcFriendList:sizepolicy(size)
  return size <= 65535
end
return CGetGrcFriendList
