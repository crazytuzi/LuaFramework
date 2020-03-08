local CGetSectionCompleteAwardReq = class("CGetSectionCompleteAwardReq")
CGetSectionCompleteAwardReq.TYPEID = 12611599
function CGetSectionCompleteAwardReq:ctor(activity_cfg_id, section_id)
  self.id = 12611599
  self.activity_cfg_id = activity_cfg_id or nil
  self.section_id = section_id or nil
end
function CGetSectionCompleteAwardReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.section_id)
end
function CGetSectionCompleteAwardReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.section_id = os:unmarshalInt32()
end
function CGetSectionCompleteAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetSectionCompleteAwardReq
