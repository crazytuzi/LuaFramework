local CGetActivityCompleteAwardReq = class("CGetActivityCompleteAwardReq")
CGetActivityCompleteAwardReq.TYPEID = 12611588
function CGetActivityCompleteAwardReq:ctor(activity_cfg_id)
  self.id = 12611588
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetActivityCompleteAwardReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetActivityCompleteAwardReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetActivityCompleteAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetActivityCompleteAwardReq
