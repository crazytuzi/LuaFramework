local SSyncSkillCommonTip = class("SSyncSkillCommonTip")
SSyncSkillCommonTip.TYPEID = 12591619
SSyncSkillCommonTip.NEED_MORE_SILVER = 0
SSyncSkillCommonTip.BAG_FULL = 1
SSyncSkillCommonTip.NEED_MORE_VIGOR = 2
function SSyncSkillCommonTip:ctor(res)
  self.id = 12591619
  self.res = res or nil
end
function SSyncSkillCommonTip:marshal(os)
  os:marshalInt32(self.res)
end
function SSyncSkillCommonTip:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SSyncSkillCommonTip:sizepolicy(size)
  return size <= 65535
end
return SSyncSkillCommonTip
