local SSyncCommonInfo = class("SSyncCommonInfo")
SSyncCommonInfo.TYPEID = 12589064
SSyncCommonInfo.VIGOR_NOT_ENOUGH = 0
SSyncCommonInfo.BAG_FULL = 1
SSyncCommonInfo.MONEY_NOT_ENOUGH = 2
SSyncCommonInfo.BANGGONG_NOT_ENOUGH = 3
SSyncCommonInfo.SKILL_REACH_MAX_LEVEL = 4
SSyncCommonInfo.NEED_SKILL_LEVELUP = 5
SSyncCommonInfo.TREASURE_BAG_FULL = 6
SSyncCommonInfo.ITEM_TYPE_MAP_BAG_ERROR = 7
SSyncCommonInfo.ITEM_TYPE_CFG_NOT_EXIST = 8
function SSyncCommonInfo:ctor(res)
  self.id = 12589064
  self.res = res or nil
end
function SSyncCommonInfo:marshal(os)
  os:marshalInt32(self.res)
end
function SSyncCommonInfo:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SSyncCommonInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncCommonInfo
