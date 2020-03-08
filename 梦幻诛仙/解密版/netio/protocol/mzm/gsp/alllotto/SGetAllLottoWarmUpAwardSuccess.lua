local SGetAllLottoWarmUpAwardSuccess = class("SGetAllLottoWarmUpAwardSuccess")
SGetAllLottoWarmUpAwardSuccess.TYPEID = 12626951
function SGetAllLottoWarmUpAwardSuccess:ctor(activity_cfg_id, warm_up_turn)
  self.id = 12626951
  self.activity_cfg_id = activity_cfg_id or nil
  self.warm_up_turn = warm_up_turn or nil
end
function SGetAllLottoWarmUpAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.warm_up_turn)
end
function SGetAllLottoWarmUpAwardSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.warm_up_turn = os:unmarshalInt32()
end
function SGetAllLottoWarmUpAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAllLottoWarmUpAwardSuccess
