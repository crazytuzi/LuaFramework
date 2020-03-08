local SGetSectionCompleteAwardSuccess = class("SGetSectionCompleteAwardSuccess")
SGetSectionCompleteAwardSuccess.TYPEID = 12611596
function SGetSectionCompleteAwardSuccess:ctor(activity_cfg_id, section_id)
  self.id = 12611596
  self.activity_cfg_id = activity_cfg_id or nil
  self.section_id = section_id or nil
end
function SGetSectionCompleteAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.section_id)
end
function SGetSectionCompleteAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.section_id = os:unmarshalInt32()
end
function SGetSectionCompleteAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetSectionCompleteAwardSuccess
