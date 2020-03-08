local CWatchmoonInviteReq = class("CWatchmoonInviteReq")
CWatchmoonInviteReq.TYPEID = 12600842
function CWatchmoonInviteReq:ctor(roleid2)
  self.id = 12600842
  self.roleid2 = roleid2 or nil
end
function CWatchmoonInviteReq:marshal(os)
  os:marshalInt64(self.roleid2)
end
function CWatchmoonInviteReq:unmarshal(os)
  self.roleid2 = os:unmarshalInt64()
end
function CWatchmoonInviteReq:sizepolicy(size)
  return size <= 65535
end
return CWatchmoonInviteReq
