local SInviteWatchmoonFailedRes = class("SInviteWatchmoonFailedRes")
SInviteWatchmoonFailedRes.TYPEID = 12600849
function SInviteWatchmoonFailedRes:ctor(rescode, errorRoleid)
  self.id = 12600849
  self.rescode = rescode or nil
  self.errorRoleid = errorRoleid or nil
end
function SInviteWatchmoonFailedRes:marshal(os)
  os:marshalInt32(self.rescode)
  os:marshalInt64(self.errorRoleid)
end
function SInviteWatchmoonFailedRes:unmarshal(os)
  self.rescode = os:unmarshalInt32()
  self.errorRoleid = os:unmarshalInt64()
end
function SInviteWatchmoonFailedRes:sizepolicy(size)
  return size <= 65535
end
return SInviteWatchmoonFailedRes
