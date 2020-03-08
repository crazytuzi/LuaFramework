local SUseManekiTokenError = class("SUseManekiTokenError")
SUseManekiTokenError.TYPEID = 12620566
SUseManekiTokenError.PRESENT_YUAN_BAO_FAIL = 1
function SUseManekiTokenError:ctor(errorCode, activityId, manekiTokenCfgId)
  self.id = 12620566
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
  self.manekiTokenCfgId = manekiTokenCfgId or nil
end
function SUseManekiTokenError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.manekiTokenCfgId)
end
function SUseManekiTokenError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
  self.manekiTokenCfgId = os:unmarshalInt32()
end
function SUseManekiTokenError:sizepolicy(size)
  return size <= 65535
end
return SUseManekiTokenError
