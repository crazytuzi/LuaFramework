local SGrcGetSelfPlatVipInfoResp = class("SGrcGetSelfPlatVipInfoResp")
SGrcGetSelfPlatVipInfoResp.TYPEID = 12600323
function SGrcGetSelfPlatVipInfoResp:ctor(retcode, plat_vip_kind)
  self.id = 12600323
  self.retcode = retcode or nil
  self.plat_vip_kind = plat_vip_kind or nil
end
function SGrcGetSelfPlatVipInfoResp:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.plat_vip_kind)
end
function SGrcGetSelfPlatVipInfoResp:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.plat_vip_kind = os:unmarshalInt32()
end
function SGrcGetSelfPlatVipInfoResp:sizepolicy(size)
  return size <= 65535
end
return SGrcGetSelfPlatVipInfoResp
