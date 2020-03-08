local OctetsStream = require("netio.OctetsStream")
local PlantTreeLog = class("PlantTreeLog")
PlantTreeLog.TYPE_ONLINR_REWARD_POINT = 1
PlantTreeLog.TYPE_ADD_POINT_OPERATION = 2
PlantTreeLog.TYPE_REMOVE_SPECIAL_STATE = 3
PlantTreeLog.TYPE_SECTION_COMPLETE = 4
PlantTreeLog.TYPE_ADD_SPECIAL_STATE = 5
function PlantTreeLog:ctor(log_type, timestamp, extradatas)
  self.log_type = log_type or nil
  self.timestamp = timestamp or nil
  self.extradatas = extradatas or {}
end
function PlantTreeLog:marshal(os)
  os:marshalInt32(self.log_type)
  os:marshalInt32(self.timestamp)
  os:marshalCompactUInt32(table.getn(self.extradatas))
  for _, v in ipairs(self.extradatas) do
    os:marshalString(v)
  end
end
function PlantTreeLog:unmarshal(os)
  self.log_type = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.extradatas, v)
  end
end
return PlantTreeLog
