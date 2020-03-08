local SLongjingUpLevelErrorRes = class("SLongjingUpLevelErrorRes")
SLongjingUpLevelErrorRes.TYPEID = 12596033
SLongjingUpLevelErrorRes.ERROR_UNKNOWN = 0
SLongjingUpLevelErrorRes.ERROR_NON_EXIST_ITEM = 1
SLongjingUpLevelErrorRes.ERROR_ITEM_NOT_ENOUGH = 2
SLongjingUpLevelErrorRes.ERROR_CAN_NOT_COMPOSE = 3
SLongjingUpLevelErrorRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 4
SLongjingUpLevelErrorRes.ERROR_IN_CROSS = 5
function SLongjingUpLevelErrorRes:ctor(resultcode)
  self.id = 12596033
  self.resultcode = resultcode or nil
end
function SLongjingUpLevelErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLongjingUpLevelErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLongjingUpLevelErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingUpLevelErrorRes
