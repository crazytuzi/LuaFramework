local SYuanBao2banggongRes = class("SYuanBao2banggongRes")
SYuanBao2banggongRes.TYPEID = 12590010
function SYuanBao2banggongRes:ctor(yuan_bao, yuan_bao_to_banggong_total)
  self.id = 12590010
  self.yuan_bao = yuan_bao or nil
  self.yuan_bao_to_banggong_total = yuan_bao_to_banggong_total or nil
end
function SYuanBao2banggongRes:marshal(os)
  os:marshalInt32(self.yuan_bao)
  os:marshalInt32(self.yuan_bao_to_banggong_total)
end
function SYuanBao2banggongRes:unmarshal(os)
  self.yuan_bao = os:unmarshalInt32()
  self.yuan_bao_to_banggong_total = os:unmarshalInt32()
end
function SYuanBao2banggongRes:sizepolicy(size)
  return size <= 65535
end
return SYuanBao2banggongRes
