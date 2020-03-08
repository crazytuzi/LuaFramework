local OctetsStream = require("netio.OctetsStream")
local RoleInfo = require("netio.protocol.mzm.gsp.alllotto.RoleInfo")
local AllLottoLog = class("AllLottoLog")
function AllLottoLog:ctor(turn, role_info)
  self.turn = turn or nil
  self.role_info = role_info or RoleInfo.new()
end
function AllLottoLog:marshal(os)
  os:marshalInt32(self.turn)
  self.role_info:marshal(os)
end
function AllLottoLog:unmarshal(os)
  self.turn = os:unmarshalInt32()
  self.role_info = RoleInfo.new()
  self.role_info:unmarshal(os)
end
return AllLottoLog
