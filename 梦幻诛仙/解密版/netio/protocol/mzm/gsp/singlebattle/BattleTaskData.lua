local OctetsStream = require("netio.OctetsStream")
local BattleTaskData = class("BattleTaskData")
function BattleTaskData:ctor(param)
  self.param = param or nil
end
function BattleTaskData:marshal(os)
  os:marshalInt32(self.param)
end
function BattleTaskData:unmarshal(os)
  self.param = os:unmarshalInt32()
end
return BattleTaskData
