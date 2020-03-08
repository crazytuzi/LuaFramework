local CUnlockGridReq = class("CUnlockGridReq")
CUnlockGridReq.TYPEID = 12584978
function CUnlockGridReq:ctor(clientYuanBao)
  self.id = 12584978
  self.clientYuanBao = clientYuanBao or nil
end
function CUnlockGridReq:marshal(os)
  os:marshalInt64(self.clientYuanBao)
end
function CUnlockGridReq:unmarshal(os)
  self.clientYuanBao = os:unmarshalInt64()
end
function CUnlockGridReq:sizepolicy(size)
  return size <= 65535
end
return CUnlockGridReq
