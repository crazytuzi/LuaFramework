local SSyncServerLevel = class("SSyncServerLevel")
SSyncServerLevel.TYPEID = 12595201
function SSyncServerLevel:ctor(level, startTime, upgradeTime, ismaxlevel)
  self.id = 12595201
  self.level = level or nil
  self.startTime = startTime or nil
  self.upgradeTime = upgradeTime or nil
  self.ismaxlevel = ismaxlevel or nil
end
function SSyncServerLevel:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt64(self.startTime)
  os:marshalInt64(self.upgradeTime)
  os:marshalInt32(self.ismaxlevel)
end
function SSyncServerLevel:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.startTime = os:unmarshalInt64()
  self.upgradeTime = os:unmarshalInt64()
  self.ismaxlevel = os:unmarshalInt32()
end
function SSyncServerLevel:sizepolicy(size)
  return size <= 65535
end
return SSyncServerLevel
