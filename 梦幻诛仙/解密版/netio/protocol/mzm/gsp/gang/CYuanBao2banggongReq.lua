local CYuanBao2banggongReq = class("CYuanBao2banggongReq")
CYuanBao2banggongReq.TYPEID = 12590009
function CYuanBao2banggongReq:ctor(yuan_bao, client_yuan_bao)
  self.id = 12590009
  self.yuan_bao = yuan_bao or nil
  self.client_yuan_bao = client_yuan_bao or nil
end
function CYuanBao2banggongReq:marshal(os)
  os:marshalInt32(self.yuan_bao)
  os:marshalInt64(self.client_yuan_bao)
end
function CYuanBao2banggongReq:unmarshal(os)
  self.yuan_bao = os:unmarshalInt32()
  self.client_yuan_bao = os:unmarshalInt64()
end
function CYuanBao2banggongReq:sizepolicy(size)
  return size <= 65535
end
return CYuanBao2banggongReq
