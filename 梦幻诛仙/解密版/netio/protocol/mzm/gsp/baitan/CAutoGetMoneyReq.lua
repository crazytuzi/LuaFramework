local CAutoGetMoneyReq = class("CAutoGetMoneyReq")
CAutoGetMoneyReq.TYPEID = 12584979
function CAutoGetMoneyReq:ctor()
  self.id = 12584979
end
function CAutoGetMoneyReq:marshal(os)
end
function CAutoGetMoneyReq:unmarshal(os)
end
function CAutoGetMoneyReq:sizepolicy(size)
  return size <= 65535
end
return CAutoGetMoneyReq
