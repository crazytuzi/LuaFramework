local SReNameStorageSuccess = class("SReNameStorageSuccess")
SReNameStorageSuccess.TYPEID = 12584811
function SReNameStorageSuccess:ctor(storageid, name)
  self.id = 12584811
  self.storageid = storageid or nil
  self.name = name or nil
end
function SReNameStorageSuccess:marshal(os)
  os:marshalInt32(self.storageid)
  os:marshalString(self.name)
end
function SReNameStorageSuccess:unmarshal(os)
  self.storageid = os:unmarshalInt32()
  self.name = os:unmarshalString()
end
function SReNameStorageSuccess:sizepolicy(size)
  return size <= 65535
end
return SReNameStorageSuccess
