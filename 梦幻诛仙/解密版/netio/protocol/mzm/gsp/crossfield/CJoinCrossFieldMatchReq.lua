local CJoinCrossFieldMatchReq = class("CJoinCrossFieldMatchReq")
CJoinCrossFieldMatchReq.TYPEID = 12619524
function CJoinCrossFieldMatchReq:ctor(activity_cfg_id)
  self.id = 12619524
  self.activity_cfg_id = activity_cfg_id or nil
end
function CJoinCrossFieldMatchReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CJoinCrossFieldMatchReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CJoinCrossFieldMatchReq:sizepolicy(size)
  return size <= 65535
end
return CJoinCrossFieldMatchReq
