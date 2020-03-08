local OctetsStream = require("netio.OctetsStream")
local Progress = class("Progress")
function Progress:ctor(chapter, section)
  self.chapter = chapter or nil
  self.section = section or nil
end
function Progress:marshal(os)
  os:marshalInt32(self.chapter)
  os:marshalInt32(self.section)
end
function Progress:unmarshal(os)
  self.chapter = os:unmarshalInt32()
  self.section = os:unmarshalInt32()
end
return Progress
