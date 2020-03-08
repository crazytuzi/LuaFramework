local SOpenNewStorageRes = class("SOpenNewStorageRes")
SOpenNewStorageRes.TYPEID = 12584812
function SOpenNewStorageRes:ctor(storageid, name, capacity)
  self.id = 12584812
  self.storageid = storageid or nil
  self.name = name or nil
  self.capacity = capacity or nil
end
function SOpenNewStorageRes:marshal(os)
  os:marshalInt32(self.storageid)
  os:marshalString(self.name)
  os:marshalInt32(self.capacity)
end
function SOpenNewStorageRes:unmarshal(os)
  self.storageid = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.capacity = os:unmarshalInt32()
end
function SOpenNewStorageRes:sizepolicy(size)
  return size <= 65535
end
return SOpenNewStorageRes
