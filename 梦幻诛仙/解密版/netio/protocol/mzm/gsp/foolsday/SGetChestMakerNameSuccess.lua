local SGetChestMakerNameSuccess = class("SGetChestMakerNameSuccess")
SGetChestMakerNameSuccess.TYPEID = 12612877
function SGetChestMakerNameSuccess:ctor(name)
  self.id = 12612877
  self.name = name or nil
end
function SGetChestMakerNameSuccess:marshal(os)
  os:marshalOctets(self.name)
end
function SGetChestMakerNameSuccess:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SGetChestMakerNameSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetChestMakerNameSuccess
