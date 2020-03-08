local CCallLevelUpDonateReq = class("CCallLevelUpDonateReq")
CCallLevelUpDonateReq.TYPEID = 12589900
function CCallLevelUpDonateReq:ctor()
  self.id = 12589900
end
function CCallLevelUpDonateReq:marshal(os)
end
function CCallLevelUpDonateReq:unmarshal(os)
end
function CCallLevelUpDonateReq:sizepolicy(size)
  return size <= 65535
end
return CCallLevelUpDonateReq
