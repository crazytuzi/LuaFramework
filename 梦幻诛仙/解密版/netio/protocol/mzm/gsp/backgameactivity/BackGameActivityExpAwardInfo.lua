local OctetsStream = require("netio.OctetsStream")
local BackGameActivityExpAwardInfo = class("BackGameActivityExpAwardInfo")
function BackGameActivityExpAwardInfo:ctor(login_count, already_get_exp_awards)
  self.login_count = login_count or nil
  self.already_get_exp_awards = already_get_exp_awards or {}
end
function BackGameActivityExpAwardInfo:marshal(os)
  os:marshalInt32(self.login_count)
  os:marshalCompactUInt32(table.getn(self.already_get_exp_awards))
  for _, v in ipairs(self.already_get_exp_awards) do
    os:marshalInt32(v)
  end
end
function BackGameActivityExpAwardInfo:unmarshal(os)
  self.login_count = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.already_get_exp_awards, v)
  end
end
return BackGameActivityExpAwardInfo
