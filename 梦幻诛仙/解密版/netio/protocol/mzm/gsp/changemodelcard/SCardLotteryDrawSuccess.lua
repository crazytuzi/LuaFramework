local SCardLotteryDrawSuccess = class("SCardLotteryDrawSuccess")
SCardLotteryDrawSuccess.TYPEID = 12624391
function SCardLotteryDrawSuccess:ctor(new_card_item_infos)
  self.id = 12624391
  self.new_card_item_infos = new_card_item_infos or {}
end
function SCardLotteryDrawSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.new_card_item_infos))
  for _, v in ipairs(self.new_card_item_infos) do
    v:marshal(os)
  end
end
function SCardLotteryDrawSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.changemodelcard.CardItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.new_card_item_infos, v)
  end
end
function SCardLotteryDrawSuccess:sizepolicy(size)
  return size <= 65535
end
return SCardLotteryDrawSuccess
