local SSyncCommonInfo = class("SSyncCommonInfo")
SSyncCommonInfo.TYPEID = 12589575
SSyncCommonInfo.MONEY_NOT_ENOUGH = 0
SSyncCommonInfo.SKILL_REACH_MAX_LEVEL = 1
function SSyncCommonInfo:ctor(res)
  self.id = 12589575
  self.res = res or nil
end
function SSyncCommonInfo:marshal(os)
  os:marshalInt32(self.res)
end
function SSyncCommonInfo:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SSyncCommonInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncCommonInfo
