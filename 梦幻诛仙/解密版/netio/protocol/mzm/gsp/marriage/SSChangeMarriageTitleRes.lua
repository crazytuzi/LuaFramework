local SSChangeMarriageTitleRes = class("SSChangeMarriageTitleRes")
SSChangeMarriageTitleRes.TYPEID = 12599830
function SSChangeMarriageTitleRes:ctor(marriageTitleCfgid)
  self.id = 12599830
  self.marriageTitleCfgid = marriageTitleCfgid or nil
end
function SSChangeMarriageTitleRes:marshal(os)
  os:marshalInt32(self.marriageTitleCfgid)
end
function SSChangeMarriageTitleRes:unmarshal(os)
  self.marriageTitleCfgid = os:unmarshalInt32()
end
function SSChangeMarriageTitleRes:sizepolicy(size)
  return size <= 65535
end
return SSChangeMarriageTitleRes
