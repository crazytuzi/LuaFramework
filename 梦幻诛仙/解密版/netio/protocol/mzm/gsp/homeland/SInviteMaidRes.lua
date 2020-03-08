local MaidInfo = require("netio.protocol.mzm.gsp.homeland.MaidInfo")
local SInviteMaidRes = class("SInviteMaidRes")
SInviteMaidRes.TYPEID = 12605456
function SInviteMaidRes:ctor(maidUuid, maidInfo)
  self.id = 12605456
  self.maidUuid = maidUuid or nil
  self.maidInfo = maidInfo or MaidInfo.new()
end
function SInviteMaidRes:marshal(os)
  os:marshalInt64(self.maidUuid)
  self.maidInfo:marshal(os)
end
function SInviteMaidRes:unmarshal(os)
  self.maidUuid = os:unmarshalInt64()
  self.maidInfo = MaidInfo.new()
  self.maidInfo:unmarshal(os)
end
function SInviteMaidRes:sizepolicy(size)
  return size <= 65535
end
return SInviteMaidRes
