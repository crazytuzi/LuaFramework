local OctetsStream = require("netio.OctetsStream")
local LotteryPetMarkItemInfo = class("LotteryPetMarkItemInfo")
function LotteryPetMarkItemInfo:ctor(item_cfg_id, count)
  self.item_cfg_id = item_cfg_id or nil
  self.count = count or nil
end
function LotteryPetMarkItemInfo:marshal(os)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.count)
end
function LotteryPetMarkItemInfo:unmarshal(os)
  self.item_cfg_id = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
return LotteryPetMarkItemInfo
