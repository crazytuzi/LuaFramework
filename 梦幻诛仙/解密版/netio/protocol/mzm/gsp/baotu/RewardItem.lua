local OctetsStream = require("netio.OctetsStream")
local RewardItem = class("RewardItem")
RewardItem.PARAM_ITEM_ID = 0
RewardItem.PARAM_ITEM_NUM = 1
RewardItem.PARAM_EXP = 2
RewardItem.PARAM_MONEY = 3
RewardItem.PARAM_MAP_ID = 4
RewardItem.PARAM_OCNTROLLER_ID = 5
RewardItem.TYPE_ITEM = 0
RewardItem.TYPE_ROLE_EXP = 1
RewardItem.TYPE_PET_EXP = 2
RewardItem.TYPE_XIULIAN_EXP = 3
RewardItem.TYPE_SILVER = 4
RewardItem.TYPE_GOLD = 5
RewardItem.TYPE_BANGGONG = 6
RewardItem.TYPE_CONTROLLER = 7
RewardItem.TYPE_YUANBAO = 8
function RewardItem:ctor(rewardType, paramMap)
  self.rewardType = rewardType or nil
  self.paramMap = paramMap or {}
end
function RewardItem:marshal(os)
  os:marshalInt32(self.rewardType)
  local _size_ = 0
  for _, _ in pairs(self.paramMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.paramMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function RewardItem:unmarshal(os)
  self.rewardType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.paramMap[k] = v
  end
end
return RewardItem
