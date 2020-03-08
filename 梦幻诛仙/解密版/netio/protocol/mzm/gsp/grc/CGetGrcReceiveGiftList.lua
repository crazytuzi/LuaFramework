local CGetGrcReceiveGiftList = class("CGetGrcReceiveGiftList")
CGetGrcReceiveGiftList.TYPEID = 12600328
function CGetGrcReceiveGiftList:ctor(page_index)
  self.id = 12600328
  self.page_index = page_index or nil
end
function CGetGrcReceiveGiftList:marshal(os)
  os:marshalInt32(self.page_index)
end
function CGetGrcReceiveGiftList:unmarshal(os)
  self.page_index = os:unmarshalInt32()
end
function CGetGrcReceiveGiftList:sizepolicy(size)
  return size <= 65535
end
return CGetGrcReceiveGiftList
