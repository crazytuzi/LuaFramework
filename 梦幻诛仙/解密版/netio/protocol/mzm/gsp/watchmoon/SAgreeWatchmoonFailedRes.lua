local SAgreeWatchmoonFailedRes = class("SAgreeWatchmoonFailedRes")
SAgreeWatchmoonFailedRes.TYPEID = 12600850
function SAgreeWatchmoonFailedRes:ctor(rescode, errorRoleid)
  self.id = 12600850
  self.rescode = rescode or nil
  self.errorRoleid = errorRoleid or nil
end
function SAgreeWatchmoonFailedRes:marshal(os)
  os:marshalInt32(self.rescode)
  os:marshalInt64(self.errorRoleid)
end
function SAgreeWatchmoonFailedRes:unmarshal(os)
  self.rescode = os:unmarshalInt32()
  self.errorRoleid = os:unmarshalInt64()
end
function SAgreeWatchmoonFailedRes:sizepolicy(size)
  return size <= 65535
end
return SAgreeWatchmoonFailedRes
