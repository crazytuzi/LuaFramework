local MemberInfo = require("netio.protocol.mzm.gsp.gang.MemberInfo")
local SSyncAddGangMember = class("SSyncAddGangMember")
SSyncAddGangMember.TYPEID = 12589830
function SSyncAddGangMember:ctor(memberInfo)
  self.id = 12589830
  self.memberInfo = memberInfo or MemberInfo.new()
end
function SSyncAddGangMember:marshal(os)
  self.memberInfo:marshal(os)
end
function SSyncAddGangMember:unmarshal(os)
  self.memberInfo = MemberInfo.new()
  self.memberInfo:unmarshal(os)
end
function SSyncAddGangMember:sizepolicy(size)
  return size <= 65535
end
return SSyncAddGangMember
