local SPetMarkLotteryDrawSuccess = class("SPetMarkLotteryDrawSuccess")
SPetMarkLotteryDrawSuccess.TYPEID = 12628508
function SPetMarkLotteryDrawSuccess:ctor(lottery_type, new_pet_mark_item_infos)
  self.id = 12628508
  self.lottery_type = lottery_type or nil
  self.new_pet_mark_item_infos = new_pet_mark_item_infos or {}
end
function SPetMarkLotteryDrawSuccess:marshal(os)
  os:marshalInt32(self.lottery_type)
  os:marshalCompactUInt32(table.getn(self.new_pet_mark_item_infos))
  for _, v in ipairs(self.new_pet_mark_item_infos) do
    v:marshal(os)
  end
end
function SPetMarkLotteryDrawSuccess:unmarshal(os)
  self.lottery_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petmark.LotteryPetMarkItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.new_pet_mark_item_infos, v)
  end
end
function SPetMarkLotteryDrawSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetMarkLotteryDrawSuccess
