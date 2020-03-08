local SImproveArtifactSuccess = class("SImproveArtifactSuccess")
SImproveArtifactSuccess.TYPEID = 12618246
function SImproveArtifactSuccess:ctor(class_id, property_type, property_value)
  self.id = 12618246
  self.class_id = class_id or nil
  self.property_type = property_type or nil
  self.property_value = property_value or nil
end
function SImproveArtifactSuccess:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.property_type)
  os:marshalInt32(self.property_value)
end
function SImproveArtifactSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.property_type = os:unmarshalInt32()
  self.property_value = os:unmarshalInt32()
end
function SImproveArtifactSuccess:sizepolicy(size)
  return size <= 65535
end
return SImproveArtifactSuccess
