local SFabaoComposeRes = class("SFabaoComposeRes")
SFabaoComposeRes.TYPEID = 12596025
SFabaoComposeRes.ERROR_UNKNOWN = 0
SFabaoComposeRes.ERROR_CFG_NON_EXSIT = 2
SFabaoComposeRes.ERROR_FRAGMENT_NOT_ENOUGH = 3
SFabaoComposeRes.ERROR_ADD_FAILED = 4
SFabaoComposeRes.ERROR_REMOVE_FAILED = 5
SFabaoComposeRes.ERROR_BAG_FULL = 6
SFabaoComposeRes.ERROR_YUANBAO_NOT_ENOUGH = 7
SFabaoComposeRes.ERROR_ITEM_PRICE_CHANGED = 8
SFabaoComposeRes.ERROR_ROLE_LEVEL_NOT_ENOUGH = 9
SFabaoComposeRes.ERROR_FA_BAO_CAN_NOT_Compose = 10
SFabaoComposeRes.ERROR_IN_CROSS = 11
function SFabaoComposeRes:ctor(resultcode)
  self.id = 12596025
  self.resultcode = resultcode or nil
end
function SFabaoComposeRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFabaoComposeRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFabaoComposeRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoComposeRes
