local SCommonResultRes = class("SCommonResultRes")
SCommonResultRes.TYPEID = 12584981
SCommonResultRes.GETITEM_FAILED_BAG_FULL = 0
SCommonResultRes.GETITEM_FAILED_ALREADY_SELLED = 1
SCommonResultRes.BUYITEM_FAILED_BAG_FULL = 2
SCommonResultRes.SELLITEM_NEED_MORE_MONEY = 4
SCommonResultRes.UNLOCK_GRID_NEED_MORE_YUANBAO = 5
SCommonResultRes.UNLOCK_GRID_SUCCESS = 6
SCommonResultRes.NOT_ENOUGH_MONEY = 7
SCommonResultRes.SILVER_TO_MAX = 8
function SCommonResultRes:ctor(res)
  self.id = 12584981
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
