local SSynPlantTreeBasicInfo = class("SSynPlantTreeBasicInfo")
SSynPlantTreeBasicInfo.TYPEID = 12611597
function SSynPlantTreeBasicInfo:ctor(owner_id, activity_cfg_id, current_section_id, current_section_point, special_state_index)
  self.id = 12611597
  self.owner_id = owner_id or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.current_section_id = current_section_id or nil
  self.current_section_point = current_section_point or nil
  self.special_state_index = special_state_index or nil
end
function SSynPlantTreeBasicInfo:marshal(os)
  os:marshalInt64(self.owner_id)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.current_section_id)
  os:marshalInt32(self.current_section_point)
  os:marshalInt32(self.special_state_index)
end
function SSynPlantTreeBasicInfo:unmarshal(os)
  self.owner_id = os:unmarshalInt64()
  self.activity_cfg_id = os:unmarshalInt32()
  self.current_section_id = os:unmarshalInt32()
  self.current_section_point = os:unmarshalInt32()
  self.special_state_index = os:unmarshalInt32()
end
function SSynPlantTreeBasicInfo:sizepolicy(size)
  return size <= 65535
end
return SSynPlantTreeBasicInfo
