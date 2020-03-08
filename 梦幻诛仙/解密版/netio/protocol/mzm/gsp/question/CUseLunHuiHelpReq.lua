local CUseLunHuiHelpReq = class("CUseLunHuiHelpReq")
CUseLunHuiHelpReq.TYPEID = 12594692
function CUseLunHuiHelpReq:ctor()
  self.id = 12594692
end
function CUseLunHuiHelpReq:marshal(os)
end
function CUseLunHuiHelpReq:unmarshal(os)
end
function CUseLunHuiHelpReq:sizepolicy(size)
  return size <= 65535
end
return CUseLunHuiHelpReq
