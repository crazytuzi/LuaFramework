local SNotifyArtifactExpire = class("SNotifyArtifactExpire")
SNotifyArtifactExpire.TYPEID = 12618257
function SNotifyArtifactExpire:ctor(class_id)
  self.id = 12618257
  self.class_id = class_id or nil
end
function SNotifyArtifactExpire:marshal(os)
  os:marshalInt32(self.class_id)
end
function SNotifyArtifactExpire:unmarshal(os)
  self.class_id = os:unmarshalInt32()
end
function SNotifyArtifactExpire:sizepolicy(size)
  return size <= 65535
end
return SNotifyArtifactExpire
