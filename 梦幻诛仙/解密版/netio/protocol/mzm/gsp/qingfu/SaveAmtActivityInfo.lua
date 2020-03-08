local OctetsStream = require("netio.OctetsStream")
local SaveAmtActivityInfo = class("SaveAmtActivityInfo")
function SaveAmtActivityInfo:ctor(base_save_amt, sortid)
  self.base_save_amt = base_save_amt or nil
  self.sortid = sortid or nil
end
function SaveAmtActivityInfo:marshal(os)
  os:marshalInt64(self.base_save_amt)
  os:marshalInt32(self.sortid)
end
function SaveAmtActivityInfo:unmarshal(os)
  self.base_save_amt = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
end
return SaveAmtActivityInfo
