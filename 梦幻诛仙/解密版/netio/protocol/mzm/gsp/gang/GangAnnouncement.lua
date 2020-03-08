local OctetsStream = require("netio.OctetsStream")
local GangAnnouncement = class("GangAnnouncement")
function GangAnnouncement:ctor(announcement, publisher, publishTime)
  self.announcement = announcement or nil
  self.publisher = publisher or nil
  self.publishTime = publishTime or nil
end
function GangAnnouncement:marshal(os)
  os:marshalString(self.announcement)
  os:marshalString(self.publisher)
  os:marshalInt64(self.publishTime)
end
function GangAnnouncement:unmarshal(os)
  self.announcement = os:unmarshalString()
  self.publisher = os:unmarshalString()
  self.publishTime = os:unmarshalInt64()
end
return GangAnnouncement
