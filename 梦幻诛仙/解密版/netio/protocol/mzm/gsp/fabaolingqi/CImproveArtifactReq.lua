local CImproveArtifactReq = class("CImproveArtifactReq")
CImproveArtifactReq.TYPEID = 12618252
function CImproveArtifactReq:ctor(class_id, property_type, use_yuanbao, client_yuanbao)
  self.id = 12618252
  self.class_id = class_id or nil
  self.property_type = property_type or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
end
function CImproveArtifactReq:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.property_type)
  os:marshalInt32(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
end
function CImproveArtifactReq:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.property_type = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalInt32()
  self.client_yuanbao = os:unmarshalInt64()
end
function CImproveArtifactReq:sizepolicy(size)
  return size <= 65535
end
return CImproveArtifactReq
