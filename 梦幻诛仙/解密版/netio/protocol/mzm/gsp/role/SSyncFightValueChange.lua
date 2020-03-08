local SSyncFightValueChange = class("SSyncFightValueChange")
SSyncFightValueChange.TYPEID = 12585991
function SSyncFightValueChange:ctor(fightValue)
  self.id = 12585991
  self.fightValue = fightValue or nil
end
function SSyncFightValueChange:marshal(os)
  os:marshalInt32(self.fightValue)
end
function SSyncFightValueChange:unmarshal(os)
  self.fightValue = os:unmarshalInt32()
end
function SSyncFightValueChange:sizepolicy(size)
  return size <= 65535
end
return SSyncFightValueChange
