local SAircraftNormalRes = class("SAircraftNormalRes")
SAircraftNormalRes.TYPEID = 12624650
SAircraftNormalRes.AIRCRAFT_NOT_OPEN = 1
SAircraftNormalRes.AIRCRAFT_CFG_NOT_EXIST = 2
SAircraftNormalRes.NOT_OWN_THE_AIRCRAFT = 3
SAircraftNormalRes.ALEARDY_OWN_THE_AIRCRAFT = 4
SAircraftNormalRes.AIRCRAFT_DYE_CFG_NOT_EXIST = 5
SAircraftNormalRes.AIRCRAFT_ITEM_NOT_EXIST = 6
SAircraftNormalRes.USER_ID_NOT_EXIST = 7
SAircraftNormalRes.ROLE_AIRCRAFT_NOT_EXIST = 8
SAircraftNormalRes.CURRENT_NO_AIRCRAFT_ON = 9
SAircraftNormalRes.SAME_WITH_AIRCRAFT_ON = 10
SAircraftNormalRes.FLY_CAN_NOT_CAKE_OFF_AIRCRAFT = 11
SAircraftNormalRes.ITEM_NOT_AIRCRAFT_TYPE = 12
SAircraftNormalRes.CUT_ITEM_ERROR = 13
SAircraftNormalRes.DYE_SAME_ERROR = 14
SAircraftNormalRes.ITEM_NOT_ENOUGH_AND_NOT_YUANBAO_ERROR = 15
SAircraftNormalRes.CLIENT_YUANBAO_NOT_SAME_WITH_SERVER_ERROR = 16
SAircraftNormalRes.CLIENT_YUANBAO_CAL_NOT_SAME_WITH_SERVER_ERROR = 17
SAircraftNormalRes.ITEM_ENOUGH_BUT_USE_YUANBAO_ERROR = 18
SAircraftNormalRes.CUT_YUANBAO_ERROR = 19
SAircraftNormalRes.CAL_YUANBAO_LESS_ZERO_ERROR = 20
SAircraftNormalRes.LEVEL_NOT_ENOUGH_ERROR = 21
SAircraftNormalRes.STATUS_ERROR = 22
function SAircraftNormalRes:ctor(ret)
  self.id = 12624650
  self.ret = ret or nil
end
function SAircraftNormalRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SAircraftNormalRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SAircraftNormalRes:sizepolicy(size)
  return size <= 65535
end
return SAircraftNormalRes
