local SUseCatItemSuccess = class("SUseCatItemSuccess")
SUseCatItemSuccess.TYPEID = 12584848
function SUseCatItemSuccess:ctor(uuid)
  self.id = 12584848
  self.uuid = uuid or nil
end
function SUseCatItemSuccess:marshal(os)
  os:marshalInt64(self.uuid)
end
function SUseCatItemSuccess:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function SUseCatItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseCatItemSuccess
