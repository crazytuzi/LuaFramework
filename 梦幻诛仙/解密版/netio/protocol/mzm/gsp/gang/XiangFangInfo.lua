local OctetsStream = require("netio.OctetsStream")
local XiangFangInfo = class("XiangFangInfo")
function XiangFangInfo:ctor(level, levelUpEndTime)
  self.level = level or nil
  self.levelUpEndTime = levelUpEndTime or nil
end
function XiangFangInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.levelUpEndTime)
end
function XiangFangInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.levelUpEndTime = os:unmarshalInt32()
end
return XiangFangInfo
