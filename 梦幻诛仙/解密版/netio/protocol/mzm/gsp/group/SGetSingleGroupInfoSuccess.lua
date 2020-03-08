local GroupInfo = require("netio.protocol.mzm.gsp.group.GroupInfo")
local SGetSingleGroupInfoSuccess = class("SGetSingleGroupInfoSuccess")
SGetSingleGroupInfoSuccess.TYPEID = 12605196
function SGetSingleGroupInfoSuccess:ctor(group_info)
  self.id = 12605196
  self.group_info = group_info or GroupInfo.new()
end
function SGetSingleGroupInfoSuccess:marshal(os)
  self.group_info:marshal(os)
end
function SGetSingleGroupInfoSuccess:unmarshal(os)
  self.group_info = GroupInfo.new()
  self.group_info:unmarshal(os)
end
function SGetSingleGroupInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetSingleGroupInfoSuccess
