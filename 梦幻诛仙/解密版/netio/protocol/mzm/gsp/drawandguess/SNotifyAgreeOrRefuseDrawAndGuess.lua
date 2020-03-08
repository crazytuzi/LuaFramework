local SNotifyAgreeOrRefuseDrawAndGuess = class("SNotifyAgreeOrRefuseDrawAndGuess")
SNotifyAgreeOrRefuseDrawAndGuess.TYPEID = 12617244
function SNotifyAgreeOrRefuseDrawAndGuess:ctor(member_roleId, operator)
  self.id = 12617244
  self.member_roleId = member_roleId or nil
  self.operator = operator or nil
end
function SNotifyAgreeOrRefuseDrawAndGuess:marshal(os)
  os:marshalInt64(self.member_roleId)
  os:marshalInt32(self.operator)
end
function SNotifyAgreeOrRefuseDrawAndGuess:unmarshal(os)
  self.member_roleId = os:unmarshalInt64()
  self.operator = os:unmarshalInt32()
end
function SNotifyAgreeOrRefuseDrawAndGuess:sizepolicy(size)
  return size <= 65535
end
return SNotifyAgreeOrRefuseDrawAndGuess
