local SUpgradeArtifactFail = class("SUpgradeArtifactFail")
SUpgradeArtifactFail.TYPEID = 12618249
SUpgradeArtifactFail.NOT_UPGRADABLE = 1
SUpgradeArtifactFail.REACH_MAXIMUM = 2
SUpgradeArtifactFail.ITEM_NOT_EXISTS = 3
SUpgradeArtifactFail.MANUAL_OPERATION_INSTEAD = 4
function SUpgradeArtifactFail:ctor(retcode, class_id)
  self.id = 12618249
  self.retcode = retcode or nil
  self.class_id = class_id or nil
end
function SUpgradeArtifactFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.class_id)
end
function SUpgradeArtifactFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.class_id = os:unmarshalInt32()
end
function SUpgradeArtifactFail:sizepolicy(size)
  return size <= 65535
end
return SUpgradeArtifactFail
