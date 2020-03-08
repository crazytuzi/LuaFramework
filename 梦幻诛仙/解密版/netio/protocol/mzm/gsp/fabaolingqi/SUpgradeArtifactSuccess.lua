local SUpgradeArtifactSuccess = class("SUpgradeArtifactSuccess")
SUpgradeArtifactSuccess.TYPEID = 12618253
function SUpgradeArtifactSuccess:ctor(class_id, level, upgrade_exp)
  self.id = 12618253
  self.class_id = class_id or nil
  self.level = level or nil
  self.upgrade_exp = upgrade_exp or nil
end
function SUpgradeArtifactSuccess:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.upgrade_exp)
end
function SUpgradeArtifactSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.upgrade_exp = os:unmarshalInt32()
end
function SUpgradeArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SUpgradeArtifactSuccess
