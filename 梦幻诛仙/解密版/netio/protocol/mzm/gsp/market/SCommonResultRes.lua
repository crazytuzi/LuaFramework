local SCommonResultRes = class("SCommonResultRes")
SCommonResultRes.TYPEID = 12601369
SCommonResultRes.GET_ITEM_FAILED_BAG_FULL = 0
SCommonResultRes.GET_ITEM_FAILED_ALREADY_SELLED = 1
SCommonResultRes.BUY_ITEM_FAILED_BAG_FULL = 2
SCommonResultRes.GET_PET_FAILED_BAG_FULL = 3
SCommonResultRes.GET_PET_FAILED_ALREADY_SELLED = 4
SCommonResultRes.BUY_PET_FAILED_BAG_FULL = 5
SCommonResultRes.ON_SHELF_MONEY_NOT_ENOUGH = 6
SCommonResultRes.ITEM_NOT_IN_SELL = 7
SCommonResultRes.PET_NOT_IN_SELL = 8
SCommonResultRes.ITEM_ALL_SELLED = 9
SCommonResultRes.PET_ALL_SELLED = 10
SCommonResultRes.GOLD_TO_MAX = 11
SCommonResultRes.CONCERN_TO_MAX = 12
SCommonResultRes.SUBTYPE_TO_MAX = 13
SCommonResultRes.PUBLIC_ITEM_CAN_NOT_RESELL = 14
SCommonResultRes.PUBLIC_PET_CAN_NOT_RESELL = 15
SCommonResultRes.CAN_NOT_BUY_CONCERN_SELF_ITEM = 16
SCommonResultRes.CAN_NOT_BUY_CONCERN_SELF_PET = 17
SCommonResultRes.SEARCH_NUM_TOMAX = 18
SCommonResultRes.ITEM_OR_PET_CAN_NOT_BUY_OR_SELL = 19
SCommonResultRes.EQUIP_CUSTOMIZED_CONDITION_ERROR = 20
SCommonResultRes.PET_CUSTOMIZED_CONDITION_ERROR = 21
SCommonResultRes.PET_EQUIP_CUSTOMIZED_CONDITION_ERROR = 22
SCommonResultRes.PET_EQUIP_SEARCH_CONDITION_ERROR = 23
SCommonResultRes.AUCTION_PRICE_ERROR = 24
SCommonResultRes.OFFSHELF_NEED_GOLD_ERROR = 25
function SCommonResultRes:ctor(res)
  self.id = 12601369
  self.res = res or nil
end
function SCommonResultRes:marshal(os)
  os:marshalInt32(self.res)
end
function SCommonResultRes:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SCommonResultRes:sizepolicy(size)
  return size <= 65535
end
return SCommonResultRes
