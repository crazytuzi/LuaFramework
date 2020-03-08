local CGrcReceiveAllGift = class("CGrcReceiveAllGift")
CGrcReceiveAllGift.TYPEID = 12600336
function CGrcReceiveAllGift:ctor()
  self.id = 12600336
end
function CGrcReceiveAllGift:marshal(os)
end
function CGrcReceiveAllGift:unmarshal(os)
end
function CGrcReceiveAllGift:sizepolicy(size)
  return size <= 65535
end
return CGrcReceiveAllGift
