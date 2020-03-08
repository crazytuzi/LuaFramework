local ActivityData = require("netio.protocol.mzm.gsp.activity.ActivityData")
local SynActivityChangeRes = class("SynActivityChangeRes")
SynActivityChangeRes.TYPEID = 12587522
function SynActivityChangeRes:ctor(activityInfo)
  self.id = 12587522
  self.activityInfo = activityInfo or ActivityData.new()
end
function SynActivityChangeRes:marshal(os)
  self.activityInfo:marshal(os)
end
function SynActivityChangeRes:unmarshal(os)
  self.activityInfo = ActivityData.new()
  self.activityInfo:unmarshal(os)
end
function SynActivityChangeRes:sizepolicy(size)
  return size <= 65535
end
return SynActivityChangeRes
