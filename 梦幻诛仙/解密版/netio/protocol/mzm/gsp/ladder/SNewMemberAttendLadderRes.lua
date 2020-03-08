local RoleLadderInfo = require("netio.protocol.mzm.gsp.ladder.RoleLadderInfo")
local SNewMemberAttendLadderRes = class("SNewMemberAttendLadderRes")
SNewMemberAttendLadderRes.TYPEID = 12607253
function SNewMemberAttendLadderRes:ctor(roleLadderInfo)
  self.id = 12607253
  self.roleLadderInfo = roleLadderInfo or RoleLadderInfo.new()
end
function SNewMemberAttendLadderRes:marshal(os)
  self.roleLadderInfo:marshal(os)
end
function SNewMemberAttendLadderRes:unmarshal(os)
  self.roleLadderInfo = RoleLadderInfo.new()
  self.roleLadderInfo:unmarshal(os)
end
function SNewMemberAttendLadderRes:sizepolicy(size)
  return size <= 65535
end
return SNewMemberAttendLadderRes
