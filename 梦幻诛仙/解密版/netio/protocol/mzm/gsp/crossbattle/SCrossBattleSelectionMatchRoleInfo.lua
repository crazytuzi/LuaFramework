local CrossBattleSelectionMatchInfo = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleSelectionMatchInfo")
local SCrossBattleSelectionMatchRoleInfo = class("SCrossBattleSelectionMatchRoleInfo")
SCrossBattleSelectionMatchRoleInfo.TYPEID = 12617003
function SCrossBattleSelectionMatchRoleInfo:ctor(fight_type, fight_stage, matchTeamAInfos, matchTeamBInfos)
  self.id = 12617003
  self.fight_type = fight_type or nil
  self.fight_stage = fight_stage or nil
  self.matchTeamAInfos = matchTeamAInfos or CrossBattleSelectionMatchInfo.new()
  self.matchTeamBInfos = matchTeamBInfos or CrossBattleSelectionMatchInfo.new()
end
function SCrossBattleSelectionMatchRoleInfo:marshal(os)
  os:marshalInt32(self.fight_type)
  os:marshalInt32(self.fight_stage)
  self.matchTeamAInfos:marshal(os)
  self.matchTeamBInfos:marshal(os)
end
function SCrossBattleSelectionMatchRoleInfo:unmarshal(os)
  self.fight_type = os:unmarshalInt32()
  self.fight_stage = os:unmarshalInt32()
  self.matchTeamAInfos = CrossBattleSelectionMatchInfo.new()
  self.matchTeamAInfos:unmarshal(os)
  self.matchTeamBInfos = CrossBattleSelectionMatchInfo.new()
  self.matchTeamBInfos:unmarshal(os)
end
function SCrossBattleSelectionMatchRoleInfo:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleSelectionMatchRoleInfo
