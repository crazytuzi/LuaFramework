local CPointRaceLeave = class("CPointRaceLeave")
CPointRaceLeave.TYPEID = 12617026
function CPointRaceLeave:ctor()
  self.id = 12617026
end
function CPointRaceLeave:marshal(os)
end
function CPointRaceLeave:unmarshal(os)
end
function CPointRaceLeave:sizepolicy(size)
  return size <= 65535
end
return CPointRaceLeave
