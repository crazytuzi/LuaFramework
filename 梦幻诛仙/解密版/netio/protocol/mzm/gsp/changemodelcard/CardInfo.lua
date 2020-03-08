local OctetsStream = require("netio.OctetsStream")
local CardInfo = class("CardInfo")
function CardInfo:ctor(card_cfg_id, level, exp, use_count)
  self.card_cfg_id = card_cfg_id or nil
  self.level = level or nil
  self.exp = exp or nil
  self.use_count = use_count or nil
end
function CardInfo:marshal(os)
  os:marshalInt32(self.card_cfg_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
  os:marshalInt32(self.use_count)
end
function CardInfo:unmarshal(os)
  self.card_cfg_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
  self.use_count = os:unmarshalInt32()
end
return CardInfo
