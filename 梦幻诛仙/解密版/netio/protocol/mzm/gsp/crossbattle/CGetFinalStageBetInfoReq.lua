local CGetFinalStageBetInfoReq = class("CGetFinalStageBetInfoReq")
CGetFinalStageBetInfoReq.TYPEID = 12617077
function CGetFinalStageBetInfoReq:ctor(activity_cfg_id, stage)
  self.id = 12617077
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
end
function CGetFinalStageBetInfoReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
end
function CGetFinalStageBetInfoReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
end
function CGetFinalStageBetInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetFinalStageBetInfoReq
