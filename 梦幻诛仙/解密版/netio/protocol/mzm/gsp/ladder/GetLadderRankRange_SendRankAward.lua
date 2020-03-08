local OctetsStream = require("netio.OctetsStream")
local GetLadderRankRange_SendRankAward = class("GetLadderRankRange_SendRankAward")
function GetLadderRankRange_SendRankAward:ctor(chart_type)
  self.chart_type = chart_type or nil
end
function GetLadderRankRange_SendRankAward:marshal(os)
  os:marshalInt32(self.chart_type)
end
function GetLadderRankRange_SendRankAward:unmarshal(os)
  self.chart_type = os:unmarshalInt32()
end
return GetLadderRankRange_SendRankAward
