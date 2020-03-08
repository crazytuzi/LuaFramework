local SSignPreciousNotifyLuckyLottery = class("SSignPreciousNotifyLuckyLottery")
SSignPreciousNotifyLuckyLottery.TYPEID = 12593426
function SSignPreciousNotifyLuckyLottery:ctor(box_type, cost_yuan_bao, precious_box_cfg_id)
  self.id = 12593426
  self.box_type = box_type or nil
  self.cost_yuan_bao = cost_yuan_bao or nil
  self.precious_box_cfg_id = precious_box_cfg_id or nil
end
function SSignPreciousNotifyLuckyLottery:marshal(os)
  os:marshalInt32(self.box_type)
  os:marshalInt32(self.cost_yuan_bao)
  os:marshalInt32(self.precious_box_cfg_id)
end
function SSignPreciousNotifyLuckyLottery:unmarshal(os)
  self.box_type = os:unmarshalInt32()
  self.cost_yuan_bao = os:unmarshalInt32()
  self.precious_box_cfg_id = os:unmarshalInt32()
end
function SSignPreciousNotifyLuckyLottery:sizepolicy(size)
  return size <= 65535
end
return SSignPreciousNotifyLuckyLottery
