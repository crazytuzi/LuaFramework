local SSyncItemExpire = class("SSyncItemExpire")
SSyncItemExpire.TYPEID = 12584967
function SSyncItemExpire:ctor(shoppingid)
  self.id = 12584967
  self.shoppingid = shoppingid or nil
end
function SSyncItemExpire:marshal(os)
  os:marshalInt64(self.shoppingid)
end
function SSyncItemExpire:unmarshal(os)
  self.shoppingid = os:unmarshalInt64()
end
function SSyncItemExpire:sizepolicy(size)
  return size <= 65535
end
return SSyncItemExpire
