local CObserveMapMonsterFight = class("CObserveMapMonsterFight")
CObserveMapMonsterFight.TYPEID = 12590953
function CObserveMapMonsterFight:ctor(instanceid)
  self.id = 12590953
  self.instanceid = instanceid or nil
end
function CObserveMapMonsterFight:marshal(os)
  os:marshalInt32(self.instanceid)
end
function CObserveMapMonsterFight:unmarshal(os)
  self.instanceid = os:unmarshalInt32()
end
function CObserveMapMonsterFight:sizepolicy(size)
  return size <= 65535
end
return CObserveMapMonsterFight
