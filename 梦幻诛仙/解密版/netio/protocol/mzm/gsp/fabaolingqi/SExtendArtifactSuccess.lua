local SExtendArtifactSuccess = class("SExtendArtifactSuccess")
SExtendArtifactSuccess.TYPEID = 12618254
function SExtendArtifactSuccess:ctor(class_id, expire_time)
  self.id = 12618254
  self.class_id = class_id or nil
  self.expire_time = expire_time or nil
end
function SExtendArtifactSuccess:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.expire_time)
end
function SExtendArtifactSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.expire_time = os:unmarshalInt32()
end
function SExtendArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SExtendArtifactSuccess
