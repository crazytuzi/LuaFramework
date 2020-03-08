local SGetActivityScheduleFail = class("SGetActivityScheduleFail")
SGetActivityScheduleFail.TYPEID = 12594435
SGetActivityScheduleFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetActivityScheduleFail.CHECK_NPC_SERVICE_ERROR = 2
function SGetActivityScheduleFail:ctor(activity_cfg_id, res)
  self.id = 12594435
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SGetActivityScheduleFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SGetActivityScheduleFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SGetActivityScheduleFail:sizepolicy(size)
  return size <= 65535
end
return SGetActivityScheduleFail
