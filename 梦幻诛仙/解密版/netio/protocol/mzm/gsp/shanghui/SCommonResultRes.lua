local SCommonResultRes = class("SCommonResultRes")
SCommonResultRes.TYPEID = 12592647
SCommonResultRes.ALL_SELLED = 0
SCommonResultRes.BUY_TOO_MUCH = 1
SCommonResultRes.NEED_1DOT5_GOLD = 2
SCommonResultRes.NEED_MORE_GOLD = 3
SCommonResultRes.BAG_FULL = 4
SCommonResultRes.SELL_TOO_MUCH = 5
SCommonResultRes.FALL_TOO_MUCH = 6
SCommonResultRes.MULTI_BUY_TOO_MUCH = 7
SCommonResultRes.MULTI_BUY_OWN_TOO_MUCH = 8
SCommonResultRes.SELL_ERROR_GOLD_MAX = 50
SCommonResultRes.GET_ITEM_ERROR_INDEX = 60
function SCommonResultRes:ctor(res)
  self.id = 12592647
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
