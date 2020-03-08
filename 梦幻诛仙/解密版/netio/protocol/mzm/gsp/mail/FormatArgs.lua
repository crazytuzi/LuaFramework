local OctetsStream = require("netio.OctetsStream")
local FormatArgs = class("FormatArgs")
function FormatArgs:ctor(args)
  self.args = args or {}
end
function FormatArgs:marshal(os)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function FormatArgs:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
return FormatArgs
