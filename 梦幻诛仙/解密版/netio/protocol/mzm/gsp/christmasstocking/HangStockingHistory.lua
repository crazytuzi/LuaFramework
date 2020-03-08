local OctetsStream = require("netio.OctetsStream")
local HangStockingHistory = class("HangStockingHistory")
function HangStockingHistory:ctor(role_id, role_name, time)
  self.role_id = role_id or nil
  self.role_name = role_name or nil
  self.time = time or nil
end
function HangStockingHistory:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.role_name)
  os:marshalInt64(self.time)
end
function HangStockingHistory:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
  self.time = os:unmarshalInt64()
end
return HangStockingHistory
