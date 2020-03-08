local SSynFengshuiRes = class("SSynFengshuiRes")
SSynFengshuiRes.TYPEID = 12605482
function SSynFengshuiRes:ctor(fengshui)
  self.id = 12605482
  self.fengshui = fengshui or nil
end
function SSynFengshuiRes:marshal(os)
  os:marshalInt32(self.fengshui)
end
function SSynFengshuiRes:unmarshal(os)
  self.fengshui = os:unmarshalInt32()
end
function SSynFengshuiRes:sizepolicy(size)
  return size <= 65535
end
return SSynFengshuiRes
