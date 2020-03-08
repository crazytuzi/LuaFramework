local GroupInfo = require("netio.protocol.mzm.gsp.group.GroupInfo")
local SCreateGroupSuccess = class("SCreateGroupSuccess")
SCreateGroupSuccess.TYPEID = 12605204
function SCreateGroupSuccess:ctor(group_info)
  self.id = 12605204
  self.group_info = group_info or GroupInfo.new()
end
function SCreateGroupSuccess:marshal(os)
  self.group_info:marshal(os)
end
function SCreateGroupSuccess:unmarshal(os)
  self.group_info = GroupInfo.new()
  self.group_info:unmarshal(os)
end
function SCreateGroupSuccess:sizepolicy(size)
  return size <= 65535
end
return SCreateGroupSuccess
