local SJoinCrossFieldMatchSuccess = class("SJoinCrossFieldMatchSuccess")
SJoinCrossFieldMatchSuccess.TYPEID = 12619526
function SJoinCrossFieldMatchSuccess:ctor(activity_cfg_id)
  self.id = 12619526
  self.activity_cfg_id = activity_cfg_id or nil
end
function SJoinCrossFieldMatchSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SJoinCrossFieldMatchSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SJoinCrossFieldMatchSuccess:sizepolicy(size)
  return size <= 65535
end
return SJoinCrossFieldMatchSuccess
