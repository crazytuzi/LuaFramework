local CGetAllLottoWarmUpAwardReq = class("CGetAllLottoWarmUpAwardReq")
CGetAllLottoWarmUpAwardReq.TYPEID = 12626953
function CGetAllLottoWarmUpAwardReq:ctor(activity_cfg_id, warm_up_turn)
  self.id = 12626953
  self.activity_cfg_id = activity_cfg_id or nil
  self.warm_up_turn = warm_up_turn or nil
end
function CGetAllLottoWarmUpAwardReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.warm_up_turn)
end
function CGetAllLottoWarmUpAwardReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.warm_up_turn = os:unmarshalInt32()
end
function CGetAllLottoWarmUpAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetAllLottoWarmUpAwardReq
