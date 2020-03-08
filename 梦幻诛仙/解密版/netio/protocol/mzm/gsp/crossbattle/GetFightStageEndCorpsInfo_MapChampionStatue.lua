local OctetsStream = require("netio.OctetsStream")
local GetFightStageEndCorpsInfo_MapChampionStatue = class("GetFightStageEndCorpsInfo_MapChampionStatue")
function GetFightStageEndCorpsInfo_MapChampionStatue:ctor(session)
  self.session = session or nil
end
function GetFightStageEndCorpsInfo_MapChampionStatue:marshal(os)
  os:marshalInt32(self.session)
end
function GetFightStageEndCorpsInfo_MapChampionStatue:unmarshal(os)
  self.session = os:unmarshalInt32()
end
return GetFightStageEndCorpsInfo_MapChampionStatue
