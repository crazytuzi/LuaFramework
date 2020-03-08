local SMakeWuQIFuRes = class("SMakeWuQIFuRes")
SMakeWuQIFuRes.TYPEID = 12589057
function SMakeWuQIFuRes:ctor(itemId)
  self.id = 12589057
  self.itemId = itemId or nil
end
function SMakeWuQIFuRes:marshal(os)
  os:marshalInt32(self.itemId)
end
function SMakeWuQIFuRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function SMakeWuQIFuRes:sizepolicy(size)
  return size <= 65535
end
return SMakeWuQIFuRes
