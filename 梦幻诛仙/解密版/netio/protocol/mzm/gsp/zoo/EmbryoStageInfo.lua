local OctetsStream = require("netio.OctetsStream")
local EmbryoStageInfo = class("EmbryoStageInfo")
function EmbryoStageInfo:ctor(embryo_cfgid, last_time, hatch_days)
  self.embryo_cfgid = embryo_cfgid or nil
  self.last_time = last_time or nil
  self.hatch_days = hatch_days or nil
end
function EmbryoStageInfo:marshal(os)
  os:marshalInt32(self.embryo_cfgid)
  os:marshalInt32(self.last_time)
  os:marshalInt32(self.hatch_days)
end
function EmbryoStageInfo:unmarshal(os)
  self.embryo_cfgid = os:unmarshalInt32()
  self.last_time = os:unmarshalInt32()
  self.hatch_days = os:unmarshalInt32()
end
return EmbryoStageInfo
