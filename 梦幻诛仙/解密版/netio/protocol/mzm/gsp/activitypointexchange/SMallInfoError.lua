local SMallInfoError = class("SMallInfoError")
SMallInfoError.TYPEID = 12624911
SMallInfoError.MALL_CLOSED = 1
function SMallInfoError:ctor(errorCode, activityId)
  self.id = 12624911
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
end
function SMallInfoError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
end
function SMallInfoError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
end
function SMallInfoError:sizepolicy(size)
  return size <= 65535
end
return SMallInfoError
