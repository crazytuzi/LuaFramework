local OctetsStream = require("netio.OctetsStream")
local CrossBattleSelectionProcessInfo = class("CrossBattleSelectionProcessInfo")
CrossBattleSelectionProcessInfo.BEGIN = 0
CrossBattleSelectionProcessInfo.GEN_TOKEN_SUC = 1
CrossBattleSelectionProcessInfo.TRANSFOR_DATA_SUC = 2
CrossBattleSelectionProcessInfo.LOGIN = 3
function CrossBattleSelectionProcessInfo:ctor(roleid, process)
  self.roleid = roleid or nil
  self.process = process or nil
end
function CrossBattleSelectionProcessInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.process)
end
function CrossBattleSelectionProcessInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.process = os:unmarshalInt32()
end
return CrossBattleSelectionProcessInfo
