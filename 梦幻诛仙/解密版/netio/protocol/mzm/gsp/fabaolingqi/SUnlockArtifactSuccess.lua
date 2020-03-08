local SUnlockArtifactSuccess = class("SUnlockArtifactSuccess")
SUnlockArtifactSuccess.TYPEID = 12618243
function SUnlockArtifactSuccess:ctor(class_id, level, expire_time)
  self.id = 12618243
  self.class_id = class_id or nil
  self.level = level or nil
  self.expire_time = expire_time or nil
end
function SUnlockArtifactSuccess:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.expire_time)
end
function SUnlockArtifactSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.expire_time = os:unmarshalInt32()
end
function SUnlockArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnlockArtifactSuccess
