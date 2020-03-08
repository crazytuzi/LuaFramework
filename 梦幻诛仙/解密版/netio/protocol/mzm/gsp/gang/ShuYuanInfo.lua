local OctetsStream = require("netio.OctetsStream")
local ShuYuanInfo = class("ShuYuanInfo")
function ShuYuanInfo:ctor(level, levelUpEndTime)
  self.level = level or nil
  self.levelUpEndTime = levelUpEndTime or nil
end
function ShuYuanInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.levelUpEndTime)
end
function ShuYuanInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.levelUpEndTime = os:unmarshalInt32()
end
return ShuYuanInfo
