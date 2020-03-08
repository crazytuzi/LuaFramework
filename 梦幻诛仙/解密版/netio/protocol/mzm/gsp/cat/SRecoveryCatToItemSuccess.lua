local SRecoveryCatToItemSuccess = class("SRecoveryCatToItemSuccess")
SRecoveryCatToItemSuccess.TYPEID = 12605716
function SRecoveryCatToItemSuccess:ctor()
  self.id = 12605716
end
function SRecoveryCatToItemSuccess:marshal(os)
end
function SRecoveryCatToItemSuccess:unmarshal(os)
end
function SRecoveryCatToItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SRecoveryCatToItemSuccess
