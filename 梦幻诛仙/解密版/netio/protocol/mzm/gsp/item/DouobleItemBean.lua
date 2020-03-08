local OctetsStream = require("netio.OctetsStream")
local DouobleItemBean = class("DouobleItemBean")
function DouobleItemBean:ctor(trigger_item_id, double_item_id, double_item_number)
  self.trigger_item_id = trigger_item_id or nil
  self.double_item_id = double_item_id or nil
  self.double_item_number = double_item_number or nil
end
function DouobleItemBean:marshal(os)
  os:marshalInt32(self.trigger_item_id)
  os:marshalInt32(self.double_item_id)
  os:marshalInt32(self.double_item_number)
end
function DouobleItemBean:unmarshal(os)
  self.trigger_item_id = os:unmarshalInt32()
  self.double_item_id = os:unmarshalInt32()
  self.double_item_number = os:unmarshalInt32()
end
return DouobleItemBean
