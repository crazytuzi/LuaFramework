local CSynBanquestReq = class("CSynBanquestReq")
CSynBanquestReq.TYPEID = 12605963
function CSynBanquestReq:ctor()
  self.id = 12605963
end
function CSynBanquestReq:marshal(os)
end
function CSynBanquestReq:unmarshal(os)
end
function CSynBanquestReq:sizepolicy(size)
  return size <= 65535
end
return CSynBanquestReq
