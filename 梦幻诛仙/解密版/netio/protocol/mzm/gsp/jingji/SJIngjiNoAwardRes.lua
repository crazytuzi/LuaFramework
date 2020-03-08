local SJIngjiNoAwardRes = class("SJIngjiNoAwardRes")
SJIngjiNoAwardRes.TYPEID = 12595729
function SJIngjiNoAwardRes:ctor()
  self.id = 12595729
end
function SJIngjiNoAwardRes:marshal(os)
end
function SJIngjiNoAwardRes:unmarshal(os)
end
function SJIngjiNoAwardRes:sizepolicy(size)
  return size <= 65535
end
return SJIngjiNoAwardRes
