local MemberInfo = require("netio.protocol.mzm.gsp.gang.MemberInfo")
local SSyncMemberInfoChange = class("SSyncMemberInfoChange")
SSyncMemberInfoChange.TYPEID = 12589896
function SSyncMemberInfoChange:ctor(memberInfo)
  self.id = 12589896
  self.memberInfo = memberInfo or MemberInfo.new()
end
function SSyncMemberInfoChange:marshal(os)
  self.memberInfo:marshal(os)
end
function SSyncMemberInfoChange:unmarshal(os)
  self.memberInfo = MemberInfo.new()
  self.memberInfo:unmarshal(os)
end
function SSyncMemberInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMemberInfoChange
