local CShouTuConditionCheck = class("CShouTuConditionCheck")
CShouTuConditionCheck.TYPEID = 12601604
function CShouTuConditionCheck:ctor(apprenticeRoleId)
  self.id = 12601604
  self.apprenticeRoleId = apprenticeRoleId or nil
end
function CShouTuConditionCheck:marshal(os)
  os:marshalInt64(self.apprenticeRoleId)
end
function CShouTuConditionCheck:unmarshal(os)
  self.apprenticeRoleId = os:unmarshalInt64()
end
function CShouTuConditionCheck:sizepolicy(size)
  return size <= 65535
end
return CShouTuConditionCheck
