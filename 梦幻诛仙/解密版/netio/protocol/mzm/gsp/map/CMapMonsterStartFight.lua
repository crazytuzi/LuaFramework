local CMapMonsterStartFight = class("CMapMonsterStartFight")
CMapMonsterStartFight.TYPEID = 12590868
function CMapMonsterStartFight:ctor(instanceId)
  self.id = 12590868
  self.instanceId = instanceId or nil
end
function CMapMonsterStartFight:marshal(os)
  os:marshalInt32(self.instanceId)
end
function CMapMonsterStartFight:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
end
function CMapMonsterStartFight:sizepolicy(size)
  return size <= 65535
end
return CMapMonsterStartFight
