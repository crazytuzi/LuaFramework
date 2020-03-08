local SUnequipArtifactSuccess = class("SUnequipArtifactSuccess")
SUnequipArtifactSuccess.TYPEID = 12618250
function SUnequipArtifactSuccess:ctor()
  self.id = 12618250
end
function SUnequipArtifactSuccess:marshal(os)
end
function SUnequipArtifactSuccess:unmarshal(os)
end
function SUnequipArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnequipArtifactSuccess
