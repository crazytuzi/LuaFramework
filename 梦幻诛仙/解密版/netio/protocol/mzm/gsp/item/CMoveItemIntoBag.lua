local CMoveItemIntoBag = class("CMoveItemIntoBag")
CMoveItemIntoBag.TYPEID = 12584805
function CMoveItemIntoBag:ctor(srckey, storageid)
  self.id = 12584805
  self.srckey = srckey or nil
  self.storageid = storageid or nil
end
function CMoveItemIntoBag:marshal(os)
  os:marshalInt32(self.srckey)
  os:marshalInt32(self.storageid)
end
function CMoveItemIntoBag:unmarshal(os)
  self.srckey = os:unmarshalInt32()
  self.storageid = os:unmarshalInt32()
end
function CMoveItemIntoBag:sizepolicy(size)
  return size <= 65535
end
return CMoveItemIntoBag
