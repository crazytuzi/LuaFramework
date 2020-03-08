local SKickByCombineNotify = class("SKickByCombineNotify")
SKickByCombineNotify.TYPEID = 12589981
function SKickByCombineNotify:ctor(gangid)
  self.id = 12589981
  self.gangid = gangid or nil
end
function SKickByCombineNotify:marshal(os)
  os:marshalInt64(self.gangid)
end
function SKickByCombineNotify:unmarshal(os)
  self.gangid = os:unmarshalInt64()
end
function SKickByCombineNotify:sizepolicy(size)
  return size <= 65535
end
return SKickByCombineNotify
