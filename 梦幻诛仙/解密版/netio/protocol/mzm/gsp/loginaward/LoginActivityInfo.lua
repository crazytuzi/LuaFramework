local OctetsStream = require("netio.OctetsStream")
local LoginActivityInfo = class("LoginActivityInfo")
function LoginActivityInfo:ctor(currentDay, sortIds, missSortIds)
  self.currentDay = currentDay or nil
  self.sortIds = sortIds or {}
  self.missSortIds = missSortIds or nil
end
function LoginActivityInfo:marshal(os)
  os:marshalInt32(self.currentDay)
  os:marshalCompactUInt32(table.getn(self.sortIds))
  for _, v in ipairs(self.sortIds) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.missSortIds)
end
function LoginActivityInfo:unmarshal(os)
  self.currentDay = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.sortIds, v)
  end
  self.missSortIds = os:unmarshalInt32()
end
return LoginActivityInfo
