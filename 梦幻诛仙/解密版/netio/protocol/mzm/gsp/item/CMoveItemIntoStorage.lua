local CMoveItemIntoStorage = class("CMoveItemIntoStorage")
CMoveItemIntoStorage.TYPEID = 12584804
function CMoveItemIntoStorage:ctor(srckey, storageid)
  self.id = 12584804
  self.srckey = srckey or nil
  self.storageid = storageid or nil
end
function CMoveItemIntoStorage:marshal(os)
  os:marshalInt32(self.srckey)
  os:marshalInt32(self.storageid)
end
function CMoveItemIntoStorage:unmarshal(os)
  self.srckey = os:unmarshalInt32()
  self.storageid = os:unmarshalInt32()
end
function CMoveItemIntoStorage:sizepolicy(size)
  return size <= 65535
end
return CMoveItemIntoStorage
