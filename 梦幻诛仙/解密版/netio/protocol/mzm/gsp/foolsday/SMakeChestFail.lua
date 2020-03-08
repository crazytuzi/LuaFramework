local SMakeChestFail = class("SMakeChestFail")
SMakeChestFail.TYPEID = 12612874
SMakeChestFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SMakeChestFail.ROLE_STATUS_ERROR = -2
SMakeChestFail.PARAM_ERROR = -3
SMakeChestFail.DB_ERROR = -4
SMakeChestFail.CAN_NOT_JOIN_ACTIVITY = 1
SMakeChestFail.MAKE_CHEST_TIME_TO_LIMIT = 2
SMakeChestFail.BUFF_CFG_ID_ERROR = 3
SMakeChestFail.VIGOR_NOT_ENOUGH = 4
SMakeChestFail.BAG_FULL = 5
function SMakeChestFail:ctor(res)
  self.id = 12612874
  self.res = res or nil
end
function SMakeChestFail:marshal(os)
  os:marshalInt32(self.res)
end
function SMakeChestFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SMakeChestFail:sizepolicy(size)
  return size <= 65535
end
return SMakeChestFail
