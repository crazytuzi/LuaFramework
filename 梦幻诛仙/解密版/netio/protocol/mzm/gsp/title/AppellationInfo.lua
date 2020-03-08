local OctetsStream = require("netio.OctetsStream")
local AppellationInfo = class("AppellationInfo")
function AppellationInfo:ctor(appellationId, appArgs, timeout)
  self.appellationId = appellationId or nil
  self.appArgs = appArgs or {}
  self.timeout = timeout or nil
end
function AppellationInfo:marshal(os)
  os:marshalInt32(self.appellationId)
  os:marshalCompactUInt32(table.getn(self.appArgs))
  for _, v in ipairs(self.appArgs) do
    os:marshalString(v)
  end
  os:marshalInt64(self.timeout)
end
function AppellationInfo:unmarshal(os)
  self.appellationId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.appArgs, v)
  end
  self.timeout = os:unmarshalInt64()
end
return AppellationInfo
