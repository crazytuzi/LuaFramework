local SImproveArtifactUseAllSuccess = class("SImproveArtifactUseAllSuccess")
SImproveArtifactUseAllSuccess.TYPEID = 12618261
function SImproveArtifactUseAllSuccess:ctor(class_id, property_type, property_value, consumed_item_num, consumed_yuanbao)
  self.id = 12618261
  self.class_id = class_id or nil
  self.property_type = property_type or nil
  self.property_value = property_value or nil
  self.consumed_item_num = consumed_item_num or nil
  self.consumed_yuanbao = consumed_yuanbao or nil
end
function SImproveArtifactUseAllSuccess:marshal(os)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.property_type)
  os:marshalInt32(self.property_value)
  os:marshalInt32(self.consumed_item_num)
  os:marshalInt32(self.consumed_yuanbao)
end
function SImproveArtifactUseAllSuccess:unmarshal(os)
  self.class_id = os:unmarshalInt32()
  self.property_type = os:unmarshalInt32()
  self.property_value = os:unmarshalInt32()
  self.consumed_item_num = os:unmarshalInt32()
  self.consumed_yuanbao = os:unmarshalInt32()
end
function SImproveArtifactUseAllSuccess:sizepolicy(size)
  return size <= 65535
end
return SImproveArtifactUseAllSuccess
