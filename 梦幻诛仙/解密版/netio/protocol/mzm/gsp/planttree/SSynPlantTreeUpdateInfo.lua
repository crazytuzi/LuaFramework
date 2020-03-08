local SSynPlantTreeUpdateInfo = class("SSynPlantTreeUpdateInfo")
SSynPlantTreeUpdateInfo.TYPEID = 12611593
function SSynPlantTreeUpdateInfo:ctor(owner_id, activity_cfg_id, current_section_id, current_section_point, special_state_index, logs)
  self.id = 12611593
  self.owner_id = owner_id or nil
  self.activity_cfg_id = activity_cfg_id or nil
  self.current_section_id = current_section_id or nil
  self.current_section_point = current_section_point or nil
  self.special_state_index = special_state_index or nil
  self.logs = logs or {}
end
function SSynPlantTreeUpdateInfo:marshal(os)
  os:marshalInt64(self.owner_id)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.current_section_id)
  os:marshalInt32(self.current_section_point)
  os:marshalInt32(self.special_state_index)
  os:marshalCompactUInt32(table.getn(self.logs))
  for _, v in ipairs(self.logs) do
    v:marshal(os)
  end
end
function SSynPlantTreeUpdateInfo:unmarshal(os)
  self.owner_id = os:unmarshalInt64()
  self.activity_cfg_id = os:unmarshalInt32()
  self.current_section_id = os:unmarshalInt32()
  self.current_section_point = os:unmarshalInt32()
  self.special_state_index = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.planttree.PlantTreeLog")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.logs, v)
  end
end
function SSynPlantTreeUpdateInfo:sizepolicy(size)
  return size <= 65535
end
return SSynPlantTreeUpdateInfo
