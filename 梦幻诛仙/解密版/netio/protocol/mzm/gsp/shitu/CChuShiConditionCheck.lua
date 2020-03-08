local CChuShiConditionCheck = class("CChuShiConditionCheck")
CChuShiConditionCheck.TYPEID = 12601614
function CChuShiConditionCheck:ctor()
  self.id = 12601614
end
function CChuShiConditionCheck:marshal(os)
end
function CChuShiConditionCheck:unmarshal(os)
end
function CChuShiConditionCheck:sizepolicy(size)
  return size <= 65535
end
return CChuShiConditionCheck
