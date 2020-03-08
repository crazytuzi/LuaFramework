local PointRaceData = require("netio.protocol.mzm.gsp.crossbattle.PointRaceData")
local SGetPointRaceDataSuccess = class("SGetPointRaceDataSuccess")
SGetPointRaceDataSuccess.TYPEID = 12617023
function SGetPointRaceDataSuccess:ctor(point_race_data)
  self.id = 12617023
  self.point_race_data = point_race_data or PointRaceData.new()
end
function SGetPointRaceDataSuccess:marshal(os)
  self.point_race_data:marshal(os)
end
function SGetPointRaceDataSuccess:unmarshal(os)
  self.point_race_data = PointRaceData.new()
  self.point_race_data:unmarshal(os)
end
function SGetPointRaceDataSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetPointRaceDataSuccess
