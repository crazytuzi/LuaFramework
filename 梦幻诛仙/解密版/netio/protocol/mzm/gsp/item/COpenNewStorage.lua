local COpenNewStorage = class("COpenNewStorage")
COpenNewStorage.TYPEID = 12584809
function COpenNewStorage:ctor(clientmoneynum)
  self.id = 12584809
  self.clientmoneynum = clientmoneynum or nil
end
function COpenNewStorage:marshal(os)
  os:marshalInt64(self.clientmoneynum)
end
function COpenNewStorage:unmarshal(os)
  self.clientmoneynum = os:unmarshalInt64()
end
function COpenNewStorage:sizepolicy(size)
  return size <= 65535
end
return COpenNewStorage
