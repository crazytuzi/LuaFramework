local SPointRaceLeaveSuccess = class("SPointRaceLeaveSuccess")
SPointRaceLeaveSuccess.TYPEID = 12617020
function SPointRaceLeaveSuccess:ctor()
  self.id = 12617020
end
function SPointRaceLeaveSuccess:marshal(os)
end
function SPointRaceLeaveSuccess:unmarshal(os)
end
function SPointRaceLeaveSuccess:sizepolicy(size)
  return size <= 65535
end
return SPointRaceLeaveSuccess
