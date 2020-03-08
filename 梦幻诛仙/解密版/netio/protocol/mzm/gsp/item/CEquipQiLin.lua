local CEquipQiLin = class("CEquipQiLin")
CEquipQiLin.TYPEID = 12584709
function CEquipQiLin:ctor(bagid, key, isUseYuanbao_qilingzhu, isUseZhenLingStone, isUseYuanbao_zhenlingstone, isUseLuckyStone, luckyStoneNum, isUseYuanbao_luckystone, costTotalYuanbao, clientSilverNum, cliStrengthLevel)
  self.id = 12584709
  self.bagid = bagid or nil
  self.key = key or nil
  self.isUseYuanbao_qilingzhu = isUseYuanbao_qilingzhu or nil
  self.isUseZhenLingStone = isUseZhenLingStone or nil
  self.isUseYuanbao_zhenlingstone = isUseYuanbao_zhenlingstone or nil
  self.isUseLuckyStone = isUseLuckyStone or nil
  self.luckyStoneNum = luckyStoneNum or nil
  self.isUseYuanbao_luckystone = isUseYuanbao_luckystone or nil
  self.costTotalYuanbao = costTotalYuanbao or nil
  self.clientSilverNum = clientSilverNum or nil
  self.cliStrengthLevel = cliStrengthLevel or nil
end
function CEquipQiLin:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.key)
  os:marshalInt32(self.isUseYuanbao_qilingzhu)
  os:marshalInt32(self.isUseZhenLingStone)
  os:marshalInt32(self.isUseYuanbao_zhenlingstone)
  os:marshalInt32(self.isUseLuckyStone)
  os:marshalInt32(self.luckyStoneNum)
  os:marshalInt32(self.isUseYuanbao_luckystone)
  os:marshalInt32(self.costTotalYuanbao)
  os:marshalInt64(self.clientSilverNum)
  os:marshalInt32(self.cliStrengthLevel)
end
function CEquipQiLin:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.isUseYuanbao_qilingzhu = os:unmarshalInt32()
  self.isUseZhenLingStone = os:unmarshalInt32()
  self.isUseYuanbao_zhenlingstone = os:unmarshalInt32()
  self.isUseLuckyStone = os:unmarshalInt32()
  self.luckyStoneNum = os:unmarshalInt32()
  self.isUseYuanbao_luckystone = os:unmarshalInt32()
  self.costTotalYuanbao = os:unmarshalInt32()
  self.clientSilverNum = os:unmarshalInt64()
  self.cliStrengthLevel = os:unmarshalInt32()
end
function CEquipQiLin:sizepolicy(size)
  return size <= 65535
end
return CEquipQiLin
