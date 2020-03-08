local SFabaoWashErrorRes = class("SFabaoWashErrorRes")
SFabaoWashErrorRes.TYPEID = 12596009
SFabaoWashErrorRes.ERROR_UNKNOWN = 0
SFabaoWashErrorRes.ERROR_CFG_NON_EXSIT = 2
SFabaoWashErrorRes.ERROR_ITEM_NOT_ENOUGH = 3
SFabaoWashErrorRes.ERROR_MONEY_NOT_ENOUGH = 4
SFabaoWashErrorRes.ERROR_CANNOT_WASH = 5
SFabaoWashErrorRes.ERROR_ITEM_PRICE_CHANGED = 6
SFabaoWashErrorRes.ERROR_CANNOT_WASH_NOT_HAS_MORE_SKILL = 7
SFabaoWashErrorRes.ERROR_IN_CROSS = 8
function SFabaoWashErrorRes:ctor(resultcode)
  self.id = 12596009
  self.resultcode = resultcode or nil
end
function SFabaoWashErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SFabaoWashErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SFabaoWashErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFabaoWashErrorRes
