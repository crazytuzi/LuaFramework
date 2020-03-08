local SSignPreciousDrawLotterySuccess = class("SSignPreciousDrawLotterySuccess")
SSignPreciousDrawLotterySuccess.TYPEID = 12593431
function SSignPreciousDrawLotterySuccess:ctor(item_id, item_num, lottery_view_id, final_index, buff_id, box_type, buff_id_n_times)
  self.id = 12593431
  self.item_id = item_id or nil
  self.item_num = item_num or nil
  self.lottery_view_id = lottery_view_id or nil
  self.final_index = final_index or nil
  self.buff_id = buff_id or nil
  self.box_type = box_type or nil
  self.buff_id_n_times = buff_id_n_times or nil
end
function SSignPreciousDrawLotterySuccess:marshal(os)
  os:marshalInt32(self.item_id)
  os:marshalInt32(self.item_num)
  os:marshalInt32(self.lottery_view_id)
  os:marshalInt32(self.final_index)
  os:marshalInt32(self.buff_id)
  os:marshalInt32(self.box_type)
  os:marshalInt32(self.buff_id_n_times)
end
function SSignPreciousDrawLotterySuccess:unmarshal(os)
  self.item_id = os:unmarshalInt32()
  self.item_num = os:unmarshalInt32()
  self.lottery_view_id = os:unmarshalInt32()
  self.final_index = os:unmarshalInt32()
  self.buff_id = os:unmarshalInt32()
  self.box_type = os:unmarshalInt32()
  self.buff_id_n_times = os:unmarshalInt32()
end
function SSignPreciousDrawLotterySuccess:sizepolicy(size)
  return size <= 65535
end
return SSignPreciousDrawLotterySuccess
