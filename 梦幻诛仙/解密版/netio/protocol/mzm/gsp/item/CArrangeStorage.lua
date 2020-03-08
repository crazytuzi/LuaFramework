local CArrangeStorage = class("CArrangeStorage")
CArrangeStorage.TYPEID = 12584808
function CArrangeStorage:ctor(storageid)
  self.id = 12584808
  self.storageid = storageid or nil
end
function CArrangeStorage:marshal(os)
  os:marshalInt32(self.storageid)
end
function CArrangeStorage:unmarshal(os)
  self.storageid = os:unmarshalInt32()
end
function CArrangeStorage:sizepolicy(size)
  return size <= 65535
end
return CArrangeStorage
