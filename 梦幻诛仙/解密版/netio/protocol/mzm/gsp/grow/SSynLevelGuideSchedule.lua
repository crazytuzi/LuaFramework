local SSynLevelGuideSchedule = class("SSynLevelGuideSchedule")
SSynLevelGuideSchedule.TYPEID = 12596998
function SSynLevelGuideSchedule:ctor(targetId, targetState)
  self.id = 12596998
  self.targetId = targetId or nil
  self.targetState = targetState or nil
end
function SSynLevelGuideSchedule:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
end
function SSynLevelGuideSchedule:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
end
function SSynLevelGuideSchedule:sizepolicy(size)
  return size <= 65535
end
return SSynLevelGuideSchedule
