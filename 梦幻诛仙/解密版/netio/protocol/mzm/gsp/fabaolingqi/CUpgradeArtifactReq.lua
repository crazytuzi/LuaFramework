local CUpgradeArtifactReq = class("CUpgradeArtifactReq")
CUpgradeArtifactReq.TYPEID = 12618242
function CUpgradeArtifactReq:ctor(class_id)
  self.id = 12618242
  self.class_id = class_id or nil
end
function CUpgradeArtifactReq:marshal(os)
  os:marshalInt32(self.class_id)
end
function CUpgradeArtifactReq:unmarshal(os)
  self.class_id = os:unmarshalInt32()
end
function CUpgradeArtifactReq:sizepolicy(size)
  return size <= 65535
end
return CUpgradeArtifactReq
