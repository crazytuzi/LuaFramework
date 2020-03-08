local OctetsStream = require("netio.OctetsStream")
local ChangeOrnament = class("ChangeOrnament")
function ChangeOrnament:ctor(add_item_cfg_id, cut_item_cfg_id)
  self.add_item_cfg_id = add_item_cfg_id or nil
  self.cut_item_cfg_id = cut_item_cfg_id or nil
end
function ChangeOrnament:marshal(os)
  os:marshalInt32(self.add_item_cfg_id)
  os:marshalInt32(self.cut_item_cfg_id)
end
function ChangeOrnament:unmarshal(os)
  self.add_item_cfg_id = os:unmarshalInt32()
  self.cut_item_cfg_id = os:unmarshalInt32()
end
return ChangeOrnament
