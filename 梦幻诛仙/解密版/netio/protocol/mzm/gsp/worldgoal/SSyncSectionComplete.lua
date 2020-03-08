local SSyncSectionComplete = class("SSyncSectionComplete")
SSyncSectionComplete.TYPEID = 12594440
function SSyncSectionComplete:ctor(activity_cfg_id, section_id)
  self.id = 12594440
  self.activity_cfg_id = activity_cfg_id or nil
  self.section_id = section_id or nil
end
function SSyncSectionComplete:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.section_id)
end
function SSyncSectionComplete:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.section_id = os:unmarshalInt32()
end
function SSyncSectionComplete:sizepolicy(size)
  return size <= 65535
end
return SSyncSectionComplete
