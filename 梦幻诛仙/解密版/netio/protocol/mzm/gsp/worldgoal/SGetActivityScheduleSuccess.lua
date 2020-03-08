local SGetActivityScheduleSuccess = class("SGetActivityScheduleSuccess")
SGetActivityScheduleSuccess.TYPEID = 12594434
function SGetActivityScheduleSuccess:ctor(activity_cfg_id, current_section_id, current_section_point, timestamp)
  self.id = 12594434
  self.activity_cfg_id = activity_cfg_id or nil
  self.current_section_id = current_section_id or nil
  self.current_section_point = current_section_point or nil
  self.timestamp = timestamp or nil
end
function SGetActivityScheduleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.current_section_id)
  os:marshalInt32(self.current_section_point)
  os:marshalInt32(self.timestamp)
end
function SGetActivityScheduleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.current_section_id = os:unmarshalInt32()
  self.current_section_point = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt32()
end
function SGetActivityScheduleSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetActivityScheduleSuccess
