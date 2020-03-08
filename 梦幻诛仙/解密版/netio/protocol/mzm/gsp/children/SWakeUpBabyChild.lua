local SWakeUpBabyChild = class("SWakeUpBabyChild")
SWakeUpBabyChild.TYPEID = 12609315
function SWakeUpBabyChild:ctor(child_id, now_tired_value)
  self.id = 12609315
  self.child_id = child_id or nil
  self.now_tired_value = now_tired_value or nil
end
function SWakeUpBabyChild:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.now_tired_value)
end
function SWakeUpBabyChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.now_tired_value = os:unmarshalInt32()
end
function SWakeUpBabyChild:sizepolicy(size)
  return size <= 65535
end
return SWakeUpBabyChild
