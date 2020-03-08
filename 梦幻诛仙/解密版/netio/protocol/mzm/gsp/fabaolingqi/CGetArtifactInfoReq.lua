local CGetArtifactInfoReq = class("CGetArtifactInfoReq")
CGetArtifactInfoReq.TYPEID = 12618258
function CGetArtifactInfoReq:ctor(role_id, class_id)
  self.id = 12618258
  self.role_id = role_id or nil
  self.class_id = class_id or nil
end
function CGetArtifactInfoReq:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.class_id)
end
function CGetArtifactInfoReq:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.class_id = os:unmarshalInt32()
end
function CGetArtifactInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetArtifactInfoReq
