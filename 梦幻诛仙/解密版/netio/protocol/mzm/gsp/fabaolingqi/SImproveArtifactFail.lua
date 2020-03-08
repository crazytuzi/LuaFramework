local SImproveArtifactFail = class("SImproveArtifactFail")
SImproveArtifactFail.TYPEID = 12618247
SImproveArtifactFail.NOT_IMPROVABLE = 1
SImproveArtifactFail.REACH_MAXIMUM = 2
SImproveArtifactFail.ITEM_NOT_EXISTS = 3
SImproveArtifactFail.ITEM_NUM_NOT_ENOUGH = 4
SImproveArtifactFail.INSUFFICIENT_YUANBAO = 5
function SImproveArtifactFail:ctor(retcode, class_id, property_type)
  self.id = 12618247
  self.retcode = retcode or nil
  self.class_id = class_id or nil
  self.property_type = property_type or nil
end
function SImproveArtifactFail:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.class_id)
  os:marshalInt32(self.property_type)
end
function SImproveArtifactFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.class_id = os:unmarshalInt32()
  self.property_type = os:unmarshalInt32()
end
function SImproveArtifactFail:sizepolicy(size)
  return size <= 65535
end
return SImproveArtifactFail
