local SGetShangHuiItemCalParams = class("SGetShangHuiItemCalParams")
SGetShangHuiItemCalParams.TYPEID = 12592655
function SGetShangHuiItemCalParams:ctor(itemId, canBuyNum, orgDayPrice, recommandPrice)
  self.id = 12592655
  self.itemId = itemId or nil
  self.canBuyNum = canBuyNum or nil
  self.orgDayPrice = orgDayPrice or nil
  self.recommandPrice = recommandPrice or nil
end
function SGetShangHuiItemCalParams:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.canBuyNum)
  os:marshalInt32(self.orgDayPrice)
  os:marshalInt32(self.recommandPrice)
end
function SGetShangHuiItemCalParams:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.canBuyNum = os:unmarshalInt32()
  self.orgDayPrice = os:unmarshalInt32()
  self.recommandPrice = os:unmarshalInt32()
end
function SGetShangHuiItemCalParams:sizepolicy(size)
  return size <= 65535
end
return SGetShangHuiItemCalParams
