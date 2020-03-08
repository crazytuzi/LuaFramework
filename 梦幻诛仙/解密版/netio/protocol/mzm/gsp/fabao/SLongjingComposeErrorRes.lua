local SLongjingComposeErrorRes = class("SLongjingComposeErrorRes")
SLongjingComposeErrorRes.TYPEID = 12596027
SLongjingComposeErrorRes.ERROR_UNKNOWN = 0
SLongjingComposeErrorRes.ERROR_NOT_HAS_COMPOSE_ITEM = 1
SLongjingComposeErrorRes.ERROR_NON_EXSIT = 2
SLongjingComposeErrorRes.ERROR_ITEM_TYPE = 3
SLongjingComposeErrorRes.ERROR_CANNOT_COMPOSE = 4
SLongjingComposeErrorRes.ERROR_BAG_FULL = 5
SLongjingComposeErrorRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 6
SLongjingComposeErrorRes.ERROR_IN_CROSS = 7
function SLongjingComposeErrorRes:ctor(resultcode)
  self.id = 12596027
  self.resultcode = resultcode or nil
end
function SLongjingComposeErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SLongjingComposeErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SLongjingComposeErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingComposeErrorRes
