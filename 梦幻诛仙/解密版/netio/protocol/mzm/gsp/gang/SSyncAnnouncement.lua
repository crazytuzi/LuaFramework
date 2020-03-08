local GangAnnouncement = require("netio.protocol.mzm.gsp.gang.GangAnnouncement")
local SSyncAnnouncement = class("SSyncAnnouncement")
SSyncAnnouncement.TYPEID = 12589892
function SSyncAnnouncement:ctor(announcement)
  self.id = 12589892
  self.announcement = announcement or GangAnnouncement.new()
end
function SSyncAnnouncement:marshal(os)
  self.announcement:marshal(os)
end
function SSyncAnnouncement:unmarshal(os)
  self.announcement = GangAnnouncement.new()
  self.announcement:unmarshal(os)
end
function SSyncAnnouncement:sizepolicy(size)
  return size <= 65535
end
return SSyncAnnouncement
