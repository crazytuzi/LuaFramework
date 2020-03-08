local CReNameStorage = class("CReNameStorage")
CReNameStorage.TYPEID = 12584807
function CReNameStorage:ctor(storageid, name)
  self.id = 12584807
  self.storageid = storageid or nil
  self.name = name or nil
end
function CReNameStorage:marshal(os)
  os:marshalInt32(self.storageid)
  os:marshalString(self.name)
end
function CReNameStorage:unmarshal(os)
  self.storageid = os:unmarshalInt32()
  self.name = os:unmarshalString()
end
function CReNameStorage:sizepolicy(size)
  return size <= 65535
end
return CReNameStorage
