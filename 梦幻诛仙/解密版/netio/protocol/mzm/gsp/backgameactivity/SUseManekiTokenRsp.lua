local SUseManekiTokenRsp = class("SUseManekiTokenRsp")
SUseManekiTokenRsp.TYPEID = 12620567
function SUseManekiTokenRsp:ctor(activityId, manekiTokenCfgId)
  self.id = 12620567
  self.activityId = activityId or nil
  self.manekiTokenCfgId = manekiTokenCfgId or nil
end
function SUseManekiTokenRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.manekiTokenCfgId)
end
function SUseManekiTokenRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.manekiTokenCfgId = os:unmarshalInt32()
end
function SUseManekiTokenRsp:sizepolicy(size)
  return size <= 65535
end
return SUseManekiTokenRsp
