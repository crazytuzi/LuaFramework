local SReachMaxLoseTimesNotify = class("SReachMaxLoseTimesNotify")
SReachMaxLoseTimesNotify.TYPEID = 12596235
function SReachMaxLoseTimesNotify:ctor()
  self.id = 12596235
end
function SReachMaxLoseTimesNotify:marshal(os)
end
function SReachMaxLoseTimesNotify:unmarshal(os)
end
function SReachMaxLoseTimesNotify:sizepolicy(size)
  return size <= 65535
end
return SReachMaxLoseTimesNotify
