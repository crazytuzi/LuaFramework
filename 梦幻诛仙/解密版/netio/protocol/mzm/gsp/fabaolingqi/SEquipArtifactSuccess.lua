local SEquipArtifactSuccess = class("SEquipArtifactSuccess")
SEquipArtifactSuccess.TYPEID = 12618251
function SEquipArtifactSuccess:ctor(class_id)
  self.id = 12618251
  self.class_id = class_id or nil
end
function SEquipArtifactSuccess:marshal(os)
  os:marshalInt32(self.class_id)
end
function SEquipArtifactSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
end
function SEquipArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SEquipArtifactSuccess
