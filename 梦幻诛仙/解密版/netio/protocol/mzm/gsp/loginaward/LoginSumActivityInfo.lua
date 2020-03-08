local OctetsStream = require("netio.OctetsStream")
local LoginSumActivityInfo = class("LoginSumActivityInfo")
function LoginSumActivityInfo:ctor(loginDays, sortIds)
  self.loginDays = loginDays or nil
  self.sortIds = sortIds or {}
end
function LoginSumActivityInfo:marshal(os)
  os:marshalInt32(self.loginDays)
  os:marshalCompactUInt32(table.getn(self.sortIds))
  for _, v in ipairs(self.sortIds) do
    os:marshalInt32(v)
  end
end
function LoginSumActivityInfo:unmarshal(os)
  self.loginDays = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.sortIds, v)
  end
end
return LoginSumActivityInfo
