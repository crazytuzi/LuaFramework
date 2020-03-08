local CEquipArtifactReq = class("CEquipArtifactReq")
CEquipArtifactReq.TYPEID = 12618244
function CEquipArtifactReq:ctor(class_id)
  self.id = 12618244
  self.class_id = class_id or nil
end
function CEquipArtifactReq:marshal(os)
  os:marshalInt32(self.class_id)
end
function CEquipArtifactReq:unmarshal(os)
  self.class_id = os:unmarshalInt32()
end
function CEquipArtifactReq:sizepolicy(size)
  return size <= 65535
end
return CEquipArtifactReq
