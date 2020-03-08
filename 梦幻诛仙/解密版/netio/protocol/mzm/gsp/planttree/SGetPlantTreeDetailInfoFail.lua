local SGetPlantTreeDetailInfoFail = class("SGetPlantTreeDetailInfoFail")
SGetPlantTreeDetailInfoFail.TYPEID = 12611585
SGetPlantTreeDetailInfoFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetPlantTreeDetailInfoFail.ROLE_STATUS_ERROR = -2
SGetPlantTreeDetailInfoFail.PARAM_ERROR = -3
SGetPlantTreeDetailInfoFail.DB_ERROR = -4
SGetPlantTreeDetailInfoFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetPlantTreeDetailInfoFail.RELATIONSHIP_ERROR = 2
function SGetPlantTreeDetailInfoFail:ctor(res)
  self.id = 12611585
  self.res = res or nil
end
function SGetPlantTreeDetailInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetPlantTreeDetailInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetPlantTreeDetailInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetPlantTreeDetailInfoFail
