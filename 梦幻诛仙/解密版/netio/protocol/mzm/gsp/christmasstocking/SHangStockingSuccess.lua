local HangStockingHistory = require("netio.protocol.mzm.gsp.christmasstocking.HangStockingHistory")
local SHangStockingSuccess = class("SHangStockingSuccess")
SHangStockingSuccess.TYPEID = 12629508
function SHangStockingSuccess:ctor(target_role_id, position, new_history)
  self.id = 12629508
  self.target_role_id = target_role_id or nil
  self.position = position or nil
  self.new_history = new_history or HangStockingHistory.new()
end
function SHangStockingSuccess:marshal(os)
  os:marshalInt64(self.target_role_id)
  os:marshalInt32(self.position)
  self.new_history:marshal(os)
end
function SHangStockingSuccess:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
  self.position = os:unmarshalInt32()
  self.new_history = HangStockingHistory.new()
  self.new_history:unmarshal(os)
end
function SHangStockingSuccess:sizepolicy(size)
  return size <= 65535
end
return SHangStockingSuccess
