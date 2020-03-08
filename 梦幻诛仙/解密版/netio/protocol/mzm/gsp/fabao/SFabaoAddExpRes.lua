local SFabaoAddExpRes = class("SFabaoAddExpRes")
SFabaoAddExpRes.TYPEID = 12595972
SFabaoAddExpRes.ERROR_UNKNOWN = 0
SFabaoAddExpRes.ERROR_CFG_NON_EXSIT = 2
SFabaoAddExpRes.ERROR_FABAO_TYPE = 3
SFabaoAddExpRes.ERROR_EXP_ITEM_TYPE = 4
SFabaoAddExpRes.ERROR_EXP_MAX_LV_FA_BAO = 5
SFabaoAddExpRes.ERROR_EXP_MAX_LV_ROLE = 6
SFabaoAddExpRes.ERROR_EXP_ITEM_NON_EXIST = 7
SFabaoAddExpRes.ERROR_EXP_ITEM_COUNT_NOT_ENOUGH = 8
SFabaoAddExpRes.ERROR_IN_CROSS = 9
function SFabaoAddExpRes:ctor(resultcode)
  self.id = 12595972
  self.resultcode = resultcode or nil
end
function SFabaoAddExpRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFabaoAddExpRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFabaoAddExpRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoAddExpRes
