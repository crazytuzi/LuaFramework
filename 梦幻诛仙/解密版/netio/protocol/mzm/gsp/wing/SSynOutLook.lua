local SSynOutLook = class("SSynOutLook")
SSynOutLook.TYPEID = 12596532
function SSynOutLook:ctor(curCfgId)
  self.id = 12596532
  self.curCfgId = curCfgId or nil
end
function SSynOutLook:marshal(os)
  os:marshalInt32(self.curCfgId)
end
function SSynOutLook:unmarshal(os)
  self.curCfgId = os:unmarshalInt32()
end
function SSynOutLook:sizepolicy(size)
  return size <= 65535
end
return SSynOutLook
