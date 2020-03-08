local SGetBackGameExpAwardSuccess = class("SGetBackGameExpAwardSuccess")
SGetBackGameExpAwardSuccess.TYPEID = 12620554
function SGetBackGameExpAwardSuccess:ctor(index)
  self.id = 12620554
  self.index = index or nil
end
function SGetBackGameExpAwardSuccess:marshal(os)
  os:marshalInt32(self.index)
end
function SGetBackGameExpAwardSuccess:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function SGetBackGameExpAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBackGameExpAwardSuccess
