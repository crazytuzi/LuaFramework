local SSyncMonsterNameChange = class("SSyncMonsterNameChange")
SSyncMonsterNameChange.TYPEID = 12590901
function SSyncMonsterNameChange:ctor(monsterInstanceId, newName)
  self.id = 12590901
  self.monsterInstanceId = monsterInstanceId or nil
  self.newName = newName or nil
end
function SSyncMonsterNameChange:marshal(os)
  os:marshalInt32(self.monsterInstanceId)
  os:marshalString(self.newName)
end
function SSyncMonsterNameChange:unmarshal(os)
  self.monsterInstanceId = os:unmarshalInt32()
  self.newName = os:unmarshalString()
end
function SSyncMonsterNameChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMonsterNameChange
