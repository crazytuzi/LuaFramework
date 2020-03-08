local OctetsStream = require("netio.OctetsStream")
local FightRecord = class("FightRecord")
function FightRecord:ctor(dieCount, killCount, reviveTime)
  self.dieCount = dieCount or nil
  self.killCount = killCount or nil
  self.reviveTime = reviveTime or nil
end
function FightRecord:marshal(os)
  os:marshalInt32(self.dieCount)
  os:marshalInt32(self.killCount)
  os:marshalInt32(self.reviveTime)
end
function FightRecord:unmarshal(os)
  self.dieCount = os:unmarshalInt32()
  self.killCount = os:unmarshalInt32()
  self.reviveTime = os:unmarshalInt32()
end
return FightRecord
