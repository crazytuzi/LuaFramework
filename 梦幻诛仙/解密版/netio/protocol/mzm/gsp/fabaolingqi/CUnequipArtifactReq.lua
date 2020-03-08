local CUnequipArtifactReq = class("CUnequipArtifactReq")
CUnequipArtifactReq.TYPEID = 12618256
function CUnequipArtifactReq:ctor()
  self.id = 12618256
end
function CUnequipArtifactReq:marshal(os)
end
function CUnequipArtifactReq:unmarshal(os)
end
function CUnequipArtifactReq:sizepolicy(size)
  return size <= 65535
end
return CUnequipArtifactReq
