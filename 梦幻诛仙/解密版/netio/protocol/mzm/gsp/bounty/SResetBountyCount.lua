local SResetBountyCount = class("SResetBountyCount")
SResetBountyCount.TYPEID = 12584199
function SResetBountyCount:ctor()
  self.id = 12584199
end
function SResetBountyCount:marshal(os)
end
function SResetBountyCount:unmarshal(os)
end
function SResetBountyCount:sizepolicy(size)
  return size <= 65535
end
return SResetBountyCount
