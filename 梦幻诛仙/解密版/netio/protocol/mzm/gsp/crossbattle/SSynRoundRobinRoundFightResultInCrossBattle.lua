local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local SSynRoundRobinRoundFightResultInCrossBattle = class("SSynRoundRobinRoundFightResultInCrossBattle")
SSynRoundRobinRoundFightResultInCrossBattle.TYPEID = 12617014
function SSynRoundRobinRoundFightResultInCrossBattle:ctor(activity_cfg_id, index, stage, fight_info)
  self.id = 12617014
  self.activity_cfg_id = activity_cfg_id or nil
  self.index = index or nil
  self.stage = stage or nil
  self.fight_info = fight_info or RoundRobinFightInfo.new()
end
function SSynRoundRobinRoundFightResultInCrossBattle:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.index)
  os:marshalInt32(self.stage)
  self.fight_info:marshal(os)
end
function SSynRoundRobinRoundFightResultInCrossBattle:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.fight_info = RoundRobinFightInfo.new()
  self.fight_info:unmarshal(os)
end
function SSynRoundRobinRoundFightResultInCrossBattle:sizepolicy(size)
  return size <= 65535
end
return SSynRoundRobinRoundFightResultInCrossBattle
