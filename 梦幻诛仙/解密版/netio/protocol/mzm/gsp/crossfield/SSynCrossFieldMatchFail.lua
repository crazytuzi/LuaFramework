local SSynCrossFieldMatchFail = class("SSynCrossFieldMatchFail")
SSynCrossFieldMatchFail.TYPEID = 12619522
SSynCrossFieldMatchFail.UNKONWN_ERROR = 0
SSynCrossFieldMatchFail.GEN_TOKEN_FAIL = 1
SSynCrossFieldMatchFail.DATA_TRANSFOR_FAIL = 2
function SSynCrossFieldMatchFail:ctor(res)
  self.id = 12619522
  self.res = res or nil
end
function SSynCrossFieldMatchFail:marshal(os)
  os:marshalInt32(self.res)
end
function SSynCrossFieldMatchFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SSynCrossFieldMatchFail:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldMatchFail
