local SImproveFail = class("SImproveFail")
SImproveFail.TYPEID = 12621059
SImproveFail.INSUFFICIENT_ITEM = 1
SImproveFail.INSUFFICIENT_YUANBAO = 2
SImproveFail.CURRENT_YUANBAO_MISMATCH = 3
SImproveFail.CANNOT_IMPROVE_ANYMORE = 4
SImproveFail.IMPROVE_TOO_MANY_PROPERTIES = 5
function SImproveFail:ctor(retcode)
  self.id = 12621059
  self.retcode = retcode or nil
end
function SImproveFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SImproveFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SImproveFail:sizepolicy(size)
  return size <= 65535
end
return SImproveFail
