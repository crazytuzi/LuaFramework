local CWakeUpBabyChild = class("CWakeUpBabyChild")
CWakeUpBabyChild.TYPEID = 12609313
function CWakeUpBabyChild:ctor(child_id)
  self.id = 12609313
  self.child_id = child_id or nil
end
function CWakeUpBabyChild:marshal(os)
  os:marshalInt64(self.child_id)
end
function CWakeUpBabyChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CWakeUpBabyChild:sizepolicy(size)
  return size <= 65535
end
return CWakeUpBabyChild
