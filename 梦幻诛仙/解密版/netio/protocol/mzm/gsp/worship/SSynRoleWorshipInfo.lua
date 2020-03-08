local SSynRoleWorshipInfo = class("SSynRoleWorshipInfo")
SSynRoleWorshipInfo.TYPEID = 12612616
function SSynRoleWorshipInfo:ctor(worshipId, lastCycleNum, thisCycleNum, canGetSalary, nextCanGetSalary)
  self.id = 12612616
  self.worshipId = worshipId or nil
  self.lastCycleNum = lastCycleNum or nil
  self.thisCycleNum = thisCycleNum or nil
  self.canGetSalary = canGetSalary or nil
  self.nextCanGetSalary = nextCanGetSalary or nil
end
function SSynRoleWorshipInfo:marshal(os)
  os:marshalInt32(self.worshipId)
  os:marshalInt32(self.lastCycleNum)
  os:marshalInt32(self.thisCycleNum)
  os:marshalInt32(self.canGetSalary)
  os:marshalInt32(self.nextCanGetSalary)
end
function SSynRoleWorshipInfo:unmarshal(os)
  self.worshipId = os:unmarshalInt32()
  self.lastCycleNum = os:unmarshalInt32()
  self.thisCycleNum = os:unmarshalInt32()
  self.canGetSalary = os:unmarshalInt32()
  self.nextCanGetSalary = os:unmarshalInt32()
end
function SSynRoleWorshipInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleWorshipInfo
