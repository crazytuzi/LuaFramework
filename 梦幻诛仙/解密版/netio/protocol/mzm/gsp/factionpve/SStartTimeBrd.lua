local SStartTimeBrd = class("SStartTimeBrd")
SStartTimeBrd.TYPEID = 12613638
function SStartTimeBrd:ctor(start_time, manager_id, manager_name, manager_duty)
  self.id = 12613638
  self.start_time = start_time or nil
  self.manager_id = manager_id or nil
  self.manager_name = manager_name or nil
  self.manager_duty = manager_duty or nil
end
function SStartTimeBrd:marshal(os)
  os:marshalInt64(self.start_time)
  os:marshalInt64(self.manager_id)
  os:marshalString(self.manager_name)
  os:marshalString(self.manager_duty)
end
function SStartTimeBrd:unmarshal(os)
  self.start_time = os:unmarshalInt64()
  self.manager_id = os:unmarshalInt64()
  self.manager_name = os:unmarshalString()
  self.manager_duty = os:unmarshalString()
end
function SStartTimeBrd:sizepolicy(size)
  return size <= 65535
end
return SStartTimeBrd
