local SOpenChestFail = class("SOpenChestFail")
SOpenChestFail.TYPEID = 12612880
SOpenChestFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SOpenChestFail.ROLE_STATUS_ERROR = -2
SOpenChestFail.PARAM_ERROR = -3
SOpenChestFail.DB_ERROR = -4
SOpenChestFail.OPEN_CHEST_TIME_TO_LIMIT = 1
SOpenChestFail.OPEN_SAME_ROLE_CHEST_TIME_TO_LIMIT = 2
SOpenChestFail.CUT_ITEM_FAIL = 3
SOpenChestFail.AWARD_FAIL = 4
SOpenChestFail.ROLE_LEVEL_NOT_ENOUGH = 5
function SOpenChestFail:ctor(res)
  self.id = 12612880
  self.res = res or nil
end
function SOpenChestFail:marshal(os)
  os:marshalInt32(self.res)
end
function SOpenChestFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SOpenChestFail:sizepolicy(size)
  return size <= 65535
end
return SOpenChestFail
