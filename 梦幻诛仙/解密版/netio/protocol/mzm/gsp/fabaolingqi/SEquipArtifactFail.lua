local SEquipArtifactFail = class("SEquipArtifactFail")
SEquipArtifactFail.TYPEID = 12618245
SEquipArtifactFail.NOT_OWN = 1
function SEquipArtifactFail:ctor(retcode, class_id)
  self.id = 12618245
  self.retcode = retcode or nil
  self.class_id = class_id or nil
end
function SEquipArtifactFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.class_id)
end
function SEquipArtifactFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.class_id = os:unmarshalInt32()
end
function SEquipArtifactFail:sizepolicy(size)
  return size <= 65535
end
return SEquipArtifactFail
