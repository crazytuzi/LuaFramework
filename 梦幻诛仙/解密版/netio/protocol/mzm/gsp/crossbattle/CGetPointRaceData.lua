local CGetPointRaceData = class("CGetPointRaceData")
CGetPointRaceData.TYPEID = 12617022
function CGetPointRaceData:ctor()
  self.id = 12617022
end
function CGetPointRaceData:marshal(os)
end
function CGetPointRaceData:unmarshal(os)
end
function CGetPointRaceData:sizepolicy(size)
  return size <= 65535
end
return CGetPointRaceData
