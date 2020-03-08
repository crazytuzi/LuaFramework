local OctetsStream = require("netio.OctetsStream")
local JinKuInfo = class("JinKuInfo")
function JinKuInfo:ctor(level, levelUpEndTime)
  self.level = level or nil
  self.levelUpEndTime = levelUpEndTime or nil
end
function JinKuInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.levelUpEndTime)
end
function JinKuInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.levelUpEndTime = os:unmarshalInt32()
end
return JinKuInfo
