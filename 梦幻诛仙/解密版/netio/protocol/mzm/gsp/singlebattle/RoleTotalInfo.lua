local OctetsStream = require("netio.OctetsStream")
local RoleBaseInfo = require("netio.protocol.mzm.gsp.singlebattle.RoleBaseInfo")
local FightRecord = require("netio.protocol.mzm.gsp.singlebattle.FightRecord")
local RoleTotalInfo = class("RoleTotalInfo")
function RoleTotalInfo:ctor(baseInfo, fightRecord)
  self.baseInfo = baseInfo or RoleBaseInfo.new()
  self.fightRecord = fightRecord or FightRecord.new()
end
function RoleTotalInfo:marshal(os)
  self.baseInfo:marshal(os)
  self.fightRecord:marshal(os)
end
function RoleTotalInfo:unmarshal(os)
  self.baseInfo = RoleBaseInfo.new()
  self.baseInfo:unmarshal(os)
  self.fightRecord = FightRecord.new()
  self.fightRecord:unmarshal(os)
end
return RoleTotalInfo
