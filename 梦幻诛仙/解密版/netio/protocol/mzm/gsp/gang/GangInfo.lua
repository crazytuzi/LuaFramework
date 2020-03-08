local OctetsStream = require("netio.OctetsStream")
local GangInfo = class("GangInfo")
function GangInfo:ctor(gangId, name, level, bangZhu, purpose, memberNum, xiangFangLevel, displayid)
  self.gangId = gangId or nil
  self.name = name or nil
  self.level = level or nil
  self.bangZhu = bangZhu or nil
  self.purpose = purpose or nil
  self.memberNum = memberNum or nil
  self.xiangFangLevel = xiangFangLevel or nil
  self.displayid = displayid or nil
end
function GangInfo:marshal(os)
  os:marshalInt64(self.gangId)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalString(self.bangZhu)
  os:marshalString(self.purpose)
  os:marshalInt32(self.memberNum)
  os:marshalInt32(self.xiangFangLevel)
  os:marshalInt64(self.displayid)
end
function GangInfo:unmarshal(os)
  self.gangId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.bangZhu = os:unmarshalString()
  self.purpose = os:unmarshalString()
  self.memberNum = os:unmarshalInt32()
  self.xiangFangLevel = os:unmarshalInt32()
  self.displayid = os:unmarshalInt64()
end
return GangInfo
