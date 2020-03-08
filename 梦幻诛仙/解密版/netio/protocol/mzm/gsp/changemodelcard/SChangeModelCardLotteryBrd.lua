local SChangeModelCardLotteryBrd = class("SChangeModelCardLotteryBrd")
SChangeModelCardLotteryBrd.TYPEID = 12624419
function SChangeModelCardLotteryBrd:ctor(role_name, item_cfg_id)
  self.id = 12624419
  self.role_name = role_name or nil
  self.item_cfg_id = item_cfg_id or nil
end
function SChangeModelCardLotteryBrd:marshal(os)
  os:marshalString(self.role_name)
  os:marshalInt32(self.item_cfg_id)
end
function SChangeModelCardLotteryBrd:unmarshal(os)
  self.role_name = os:unmarshalString()
  self.item_cfg_id = os:unmarshalInt32()
end
function SChangeModelCardLotteryBrd:sizepolicy(size)
  return size <= 65535
end
return SChangeModelCardLotteryBrd
